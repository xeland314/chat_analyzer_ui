import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import '../common/emoji_rich_text.dart';
import '../chat/chat_helpers.dart';

class CommunicationGraphView extends StatelessWidget {
  final Map<String, Map<String, int>> replies;

  const CommunicationGraphView({super.key, required this.replies});

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) {
      return const SizedBox.shrink();
    }

    final graph = Graph();
    final nodes = <String, Node>{};

    // Add nodes
    for (final participant in replies.keys) {
      nodes[participant] = Node.Id(participant);
      graph.addNode(nodes[participant]!);
    }

    // Add edges
    replies.forEach((replier, repliees) {
      repliees.forEach((repliee, count) {
        if (count > 0) {
          graph.addEdge(
            nodes[replier]!,
            nodes[repliee]!,
            paint: Paint()
              ..color = Colors.red
              ..strokeWidth = 2,
          );
        }
      });
    });

    final builder = FruchtermanReingoldAlgorithm();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Communication Graph',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 400,
          child: InteractiveViewer(
            constrained: false,
            boundaryMargin: const EdgeInsets.all(100),
            minScale: 0.01,
            maxScale: 5.6,
            child: GraphView(
              graph: graph,
              algorithm: builder,
              paint: Paint()
                ..color = Colors.green
                ..strokeWidth = 1
                ..style = PaintingStyle.stroke,
              builder: (Node node) {
                final participant = node.key!.value as String;
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: emojiRichText(
                    getInitials(participant),
                    baseStyle: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
