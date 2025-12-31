import 'package:flutter/material.dart';
import 'package:flutter_force_directed_graph/flutter_force_directed_graph.dart';
import '../../chat/chat_avatar.dart';
import '../../../src/analysis/pagerank.dart';
import '../../../l10n/app_localizations.dart';

class InteractiveNetworkGraph extends StatefulWidget {
  final Map<String, Map<String, int>> replies;

  const InteractiveNetworkGraph({super.key, required this.replies});

  @override
  State<InteractiveNetworkGraph> createState() =>
      _InteractiveNetworkGraphState();
}

class _InteractiveNetworkGraphState extends State<InteractiveNetworkGraph> {
  String? _selectedNode;
  late ForceDirectedGraphController<String> _controller;
  final Map<String, Color> _edgeColors = {};
  late Map<String, double> _nodeRadii;

  @override
  void initState() {
    super.initState();
    _controller = ForceDirectedGraphController();

    // 1. Calcular PageRank
    final pageRanks = calculateWeightedPageRank(widget.replies);
    final maxRank = pageRanks.values.reduce((a, b) => a > b ? a : b);
    final minRank = pageRanks.values.reduce((a, b) => a < b ? a : b);

    // 2. Calcular radio para cada nodo (entre 20 y 80)
    _nodeRadii = {};
    for (final participant in widget.replies.keys) {
      final rank = pageRanks[participant] ?? 0;
      double radius;
      if (maxRank == minRank) {
        radius = 50.0; // valor medio si todos son iguales
      } else {
        // Normaliza entre 0 y 1, luego escala a [20, 80]
        final normalized = (rank - minRank) / (maxRank - minRank);
        radius = 20.0 + normalized * 60.0; // 20 + (0→1)*60 = 20→80
      }
      _nodeRadii[participant] = radius;
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getEdgeKey(String a, String b) {
    return a.compareTo(b) < 0 ? '$a-$b' : '$b-$a';
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
        const SizedBox(height: 16),
        SizedBox(
          height: 600,
          child: ForceDirectedGraphWidget(
            controller: _controller,
            nodesBuilder: (context, participant) {
              final isSelected = participant == _selectedNode;
              final radius = _nodeRadii[participant] ?? 20.0;

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
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.teal, width: 3)
                        : null,
                  ),
                  child: authorAvatar(participant, radius: radius),
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
