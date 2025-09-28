import 'package:flutter/material.dart';
import '../../../src/analysis/matrix_operations.dart';
import '../../chat/chat_avatar.dart';

class TopBrokersCards extends StatelessWidget {
  final Map<String, Map<String, int>> replies;

  const TopBrokersCards({super.key, required this.replies});

  Map<String, int> _calculateBrokerScores() {
    final matrixSquared = squareMatrix(replies);
    final brokerScores = <String, int>{};

    for (final p1 in replies.keys) {
      int score = 0;
      for (final p2 in replies.keys) {
        if (p1 != p2) {
          // Exclude self-loops
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

    final topBrokers = sortedBrokers.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Brokers',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...topBrokers.map((broker) => _buildBrokerCard(broker)),
      ],
    );
  }

  Widget _buildBrokerCard(MapEntry<String, int> broker) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            authorAvatar(broker.key),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(broker.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Broker Score: ${broker.value}'),
                  const SizedBox(height: 4),
                  const Text(
                    'This user acts as a bridge in the conversation.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
