import 'package:flutter/material.dart';
import '../common/emoji_rich_text.dart';

class ReciprocityHeatmapView extends StatelessWidget {
  final Map<String, Map<String, int>> replies;

  const ReciprocityHeatmapView({super.key, required this.replies});

  double _calculateReciprocityPerPair(String p1, String p2) {
    final m_ij = replies[p1]?[p2] ?? 0;
    final m_ji = replies[p2]?[p1] ?? 0;

    if (m_ij == 0 && m_ji == 0) {
      return 0.0; // Define as 0 if both are 0
    }

    return (m_ij < m_ji ? m_ij : m_ji) / (m_ij > m_ji ? m_ij : m_ji);
  }

  Color _getColorForReciprocity(double reciprocity) {
    if (reciprocity == 0.0) return Colors.grey.shade900; // No interaction
    if (reciprocity < 0.25) return Colors.red.shade900;
    if (reciprocity < 0.5) return Colors.orange.shade900;
    if (reciprocity < 0.75) return Colors.yellow.shade900;
    return Colors.green.shade900; // Highly reciprocal
  }

  @override
  Widget build(BuildContext context) {
    final participants = replies.keys.toList()..sort();
    if (participants.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Reciprocity Heatmap',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              const DataColumn(label: Text('From \\ To')),
              ...participants.map(
                (p) => DataColumn(
                  label: emojiRichText(
                    p,
                    baseStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
            rows: participants.map((p1) {
              return DataRow(
                cells: [
                  DataCell(
                    emojiRichText(
                      p1,
                      baseStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...participants.map((p2) {
                    final reciprocity = _calculateReciprocityPerPair(p1, p2);
                    return DataCell(
                      Container(
                        color: _getColorForReciprocity(reciprocity),
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          reciprocity.toStringAsFixed(2),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
