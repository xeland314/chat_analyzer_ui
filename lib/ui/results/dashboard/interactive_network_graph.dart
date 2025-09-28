import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import '../../../src/analysis/pagerank.dart';
import '../../chat/chat_avatar.dart';

class InteractiveNetworkGraph extends StatefulWidget {
  final Map<String, Map<String, int>> replies;

  const InteractiveNetworkGraph({super.key, required this.replies});

  @override
  State<InteractiveNetworkGraph> createState() => _InteractiveNetworkGraphState();
}

class _InteractiveNetworkGraphState extends State<InteractiveNetworkGraph> {
  Node? _selectedNode;

  Map<String, List<String>> _createGraphData() {
    final graphData = <String, List<String>>{};
    widget.replies.forEach((replier, repliees) {
      graphData[replier] = repliees.keys.toList();
    });
    return graphData;
  }

  @override
  Widget build(BuildContext context) {
    final graph = Graph();
    final nodes = <String, Node>{};

    final pageRanks = calculatePageRank(_createGraphData());
    final maxRank = pageRanks.values.reduce((a, b) => a > b ? a : b);
    final minRank = pageRanks.values.reduce((a, b) => a < b ? a : b);

    for (final participant in widget.replies.keys) {
      nodes[participant] = Node.Id(participant);
    }

    for (final replier in widget.replies.keys) {
      for (final repliee in widget.replies[replier]!.keys) {
        final count = widget.replies[replier]![repliee]!;
        if (count > 0) {
          var color = Colors.grey;
          if (_selectedNode != null) {
            if (replier == _selectedNode!.key!.value ||
                repliee == _selectedNode!.key!.value) {
              color = Colors.teal;
            }
          }
          graph.addEdge(nodes[replier]!, nodes[repliee]!,
              paint: Paint()
                ..color = color
                ..strokeWidth = (count / 2).clamp(0.5, 5.0));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Communication Network',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: GraphView(
            graph: graph,
            algorithm: FruchtermanReingoldAlgorithm(),
            builder: (Node node) {
              final participant = node.key!.value as String;
              final rank = pageRanks[participant] ?? 0;
              final radius = (maxRank - minRank) == 0
                  ? 20.0
                  : 20 + ((rank - minRank) / (maxRank - minRank)) * 20;

              final isSelected = node == _selectedNode;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedNode == node) {
                      _selectedNode = null;
                    } else {
                      _selectedNode = node;
                    }
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
          ),
        ),
      ],
    );
  }
}
