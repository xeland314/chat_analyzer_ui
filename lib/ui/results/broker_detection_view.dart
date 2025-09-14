import 'package:flutter/material.dart';
import '../../src/analysis/matrix_operations.dart';
import '../common/emoji_rich_text.dart';

class BrokerDetectionView extends StatelessWidget {
  final Map<String, Map<String, int>> replies;

  const BrokerDetectionView({super.key, required this.replies});

  Map<String, int> _calculateBrokerScores() {
    final matrixSquared = squareMatrix(replies);
    final brokerScores = <String, int>{};

    for (final p1 in replies.keys) {
      int score = 0;
      for (final p2 in replies.keys) {
        if (p1 != p2) { // Exclude self-loops
          score += matrixSquared[p1]?[p2] ?? 0;
        }
      }
      brokerScores[p1] = score;
    }
    return brokerScores;
  }

  @override
  Widget build(BuildContext context) {
    final brokerScores = _calculateBrokerScores();
    final sortedBrokers = brokerScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Top Brokers (Indirect Communication Facilitators)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        DataTable(
          columns: const [
            DataColumn(label: Text('Participant')),
            DataColumn(label: Text('Broker Score')),
          ],
          rows: sortedBrokers.map((entry) {
            return DataRow(
              cells: [
                DataCell(emojiRichText(entry.key)),
                DataCell(Text(entry.value.toString())),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
