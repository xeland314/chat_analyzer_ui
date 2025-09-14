import 'package:flutter/material.dart';
import '../../src/analysis/matrix_operations.dart';
import '../common/emoji_rich_text.dart';

class MarkovChainView extends StatelessWidget {
  final Map<String, Map<String, int>> replies;

  const MarkovChainView({super.key, required this.replies});

  @override
  Widget build(BuildContext context) {
    final transitionMatrix = normalizeMatrix(replies);
    final participants = transitionMatrix.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Markov Chain - Transition Probabilities',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              const DataColumn(label: Text('From \ To')),
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
                    final prob = transitionMatrix[p1]?[p2] ?? 0;
                    return DataCell(Text(prob.toStringAsFixed(2)));
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
