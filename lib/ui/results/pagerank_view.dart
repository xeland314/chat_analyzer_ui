import 'package:flutter/material.dart';
import '../../src/analysis/pagerank.dart';
import '../common/emoji_rich_text.dart';

class PageRankView extends StatelessWidget {
  final Map<String, Map<String, int>> replies;

  const PageRankView({super.key, required this.replies});

  Map<String, List<String>> _createGraph() {
    final graph = <String, List<String>>{};
    replies.forEach((replier, repliees) {
      graph[replier] = repliees.keys.toList();
    });
    return graph;
  }

  @override
  Widget build(BuildContext context) {
    final graph = _createGraph();
    final pageRanks = calculatePageRank(graph);
    final sortedRanks = pageRanks.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Influence Ranking (PageRank)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        DataTable(
          columns: const [
            DataColumn(label: Text('Participant')),
            DataColumn(label: Text('Score')),
          ],
          rows: sortedRanks.map((entry) {
            return DataRow(
              cells: [
                DataCell(emojiRichText(entry.key)),
                DataCell(Text(entry.value.toStringAsFixed(3))),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
