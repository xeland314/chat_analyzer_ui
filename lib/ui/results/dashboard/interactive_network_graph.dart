import 'package:flutter/material.dart';
import 'package:flutter_force_directed_graph/flutter_force_directed_graph.dart';
import '../../chat/chat_avatar.dart';
import '../../../src/analysis/pagerank.dart';
import '../../../l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SizeMode { uniform, influence }

class InteractiveNetworkGraph extends StatefulWidget {
  final Map<String, Map<String, int>> replies;

  const InteractiveNetworkGraph({super.key, required this.replies});

  @override
  State<InteractiveNetworkGraph> createState() =>
      _InteractiveNetworkGraphState();
}

class _InteractiveNetworkGraphState extends State<InteractiveNetworkGraph> with TickerProviderStateMixin {
  String? _selectedNode;
  late ForceDirectedGraphController<String> _controller;
  final Map<String, Color> _edgeColors = {};
  late Map<String, double> _nodeRadii;

  // Preference key and state for size mode
  static const _prefKeySizeMode = 'network_avatar_size_mode';
  SizeMode _sizeMode = SizeMode.uniform;

  // Radios base calculadas por influencia (no escaladas por pantalla)
  late Map<String, double> _influenceRadii;

  @override
  void initState() {
    super.initState();
    _controller = ForceDirectedGraphController();

    // 1. Calcular PageRank
    final pageRanks = calculateWeightedPageRank(widget.replies);
    final maxRank = pageRanks.values.reduce((a, b) => a > b ? a : b);
    final minRank = pageRanks.values.reduce((a, b) => a < b ? a : b);

    // 2. Calcular radio base para cada nodo (entre 20 y 80) según PageRank
    _influenceRadii = {};
    _nodeRadii = {};
    for (final participant in widget.replies.keys) {
      final rank = pageRanks[participant] ?? 0;
      double radiusBase;
      if (maxRank == minRank) {
        radiusBase = 50.0; // valor medio si todos son iguales
      } else {
        final normalized = (rank - minRank) / (maxRank - minRank);
        radiusBase = 20.0 + normalized * 60.0; // 20→80
      }
      _influenceRadii[participant] = radiusBase;
      _nodeRadii[participant] = radiusBase;
    }

    // Primero los nodos
    for (final participant in widget.replies.keys) {
      _controller.addNode(participant);
    }

    // Después las aristas
    final Set<String> addedEdges = {};
    for (final replier in widget.replies.keys) {
      for (final repliee in widget.replies[replier]!.keys) {
        if (replier == repliee) continue;

        final count = widget.replies[replier]![repliee]!;
        if (count > 0) {
          final key = _getEdgeKey(replier, repliee);
          if (!addedEdges.contains(key)) {
            _controller.addEdgeByData(replier, repliee);
            addedEdges.add(key);
          }
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.needUpdate();
    });

    // Cargar preferencia de modo de tamaño
    _loadSizeMode();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getEdgeKey(String a, String b) {
    return a.compareTo(b) < 0 ? '$a-$b' : '$b-$a';
  }

  Future<void> _loadSizeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString(_prefKeySizeMode);
    setState(() {
      if (val == 'influence') {
        _sizeMode = SizeMode.influence;
      } else {
        _sizeMode = SizeMode.uniform;
      }
    });
  }

  Future<void> _saveSizeMode(SizeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeySizeMode, mode == SizeMode.influence ? 'influence' : 'uniform');
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.interactive_network_graph_title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        // Toggle para elegir modo de tamaño (responsive)
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text(appLocalizations.network_size_mode_label),
              ToggleButtons(
                isSelected: [
                  _sizeMode == SizeMode.influence,
                  _sizeMode == SizeMode.uniform,
                ],
                onPressed: (index) {
                  final newMode = index == 0 ? SizeMode.influence : SizeMode.uniform;
                  setState(() {
                    _sizeMode = newMode;
                  });
                  _saveSizeMode(newMode);
                  _controller.needUpdate();
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(appLocalizations.network_size_mode_influence),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(appLocalizations.network_size_mode_uniform),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 600,
          child: ForceDirectedGraphWidget(
            controller: _controller,
            nodesBuilder: (context, participant) {
              final isSelected = participant == _selectedNode;
              // Calcular tamaño mostrado según modo y tamaño de pantalla
              final screenWidth = MediaQuery.of(context).size.width;
              double uniformSize = 20.0;
              if (screenWidth < 360) {
                uniformSize = 16.0;
              } else if (screenWidth > 1000) {
                uniformSize = 24.0;
              }

              final scaleFactor = (screenWidth / 800).clamp(0.7, 1.4);

              final radius = _sizeMode == SizeMode.uniform
                  ? uniformSize
                  : ((_influenceRadii[participant] ?? 20.0) * scaleFactor).clamp(10.0, 120.0);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedNode == participant) {
                      _selectedNode = null;
                      _edgeColors.clear();
                    } else {
                      _selectedNode = participant;
                      _edgeColors.clear();

                      // Iterate edges in internal graph representation
                      for (final edge in _controller.graph.edges) {
                        // Deduce cómo acceder a los extremos del edge; aquí asumo `edge.from` y `edge.to`
                        final from = edge.a.data;
                        final to = edge.b.data;

                        final key = _getEdgeKey(from.toString(), to.toString());
                        if (from == participant || to == participant) {
                          _edgeColors[key] = Colors.teal;
                        } else {
                          _edgeColors[key] = Colors.grey.withValues(alpha: 0.2);
                        }
                      }
                    }
                    _controller.needUpdate();
                  });
                },
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.teal, width: 3)
                          : null,
                    ),
                    child: authorAvatar(participant, radius: radius),
                  ),
                ),
              );
            },
            edgesBuilder: (context, a, b, distance) {
              final key = _getEdgeKey(a, b);
              final color = _edgeColors[key] ?? Colors.grey;
              final count = widget.replies[a]?[b] ?? widget.replies[b]?[a] ?? 0;
              final strokeWidth = (count / 2).clamp(0.5, 5.0);

              return Container(
                width: distance,
                height: strokeWidth,
                color: color,
              );
            },
          ),
        ),
      ],
    );
  }
}
