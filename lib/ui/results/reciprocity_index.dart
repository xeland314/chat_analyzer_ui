import 'package:flutter/material.dart';

class ReciprocityIndex extends StatelessWidget {
  final Map<String, Map<String, int>> replies;

  const ReciprocityIndex({super.key, required this.replies});

  double _calculateReciprocityIndex() {
    double minSum = 0;
    double maxSum = 0;

    final participants = replies.keys.toList();

    for (int i = 0; i < participants.length; i++) {
      for (int j = i + 1; j < participants.length; j++) {
        final p1 = participants[i];
        final p2 = participants[j];

        final m_ij = replies[p1]?[p2] ?? 0;
        final m_ji = replies[p2]?[p1] ?? 0;

        minSum += m_ij < m_ji ? m_ij : m_ji;
        maxSum += m_ij > m_ji ? m_ij : m_ji;
      }
    }

    if (maxSum == 0) {
      return 0;
    }

    return minSum / maxSum;
  }

  @override
  Widget build(BuildContext context) {
    final reciprocityIndex = _calculateReciprocityIndex();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Communication Symmetry',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Reciprocity Index: ${reciprocityIndex.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 4),
        Text(
          '(1 = symmetric, 0 = asymmetric)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
