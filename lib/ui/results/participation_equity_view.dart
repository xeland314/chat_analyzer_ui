import 'package:flutter/material.dart';
import '../../src/analysis/matrix_operations.dart';

class ParticipationEquityView extends StatelessWidget {
  final Map<String, Map<String, int>> replies;

  const ParticipationEquityView({super.key, required this.replies});

  @override
  Widget build(BuildContext context) {
    final participants = replies.keys.toList()..sort();
    if (participants.isEmpty) return const SizedBox.shrink();

    final outDegreeValues = <int>[];
    final inDegreeValues = <int>[];

    final outDegree = <String, int>{};
    final inDegree = <String, int>{};
    for (final p1 in participants) {
      outDegree[p1] = 0;
      inDegree[p1] = 0;
    }

    for (final replier in participants) {
      for (final repliee in participants) {
        final count = replies[replier]?[repliee] ?? 0;
        outDegree[replier] = (outDegree[replier] ?? 0) + count;
        inDegree[repliee] = (inDegree[repliee] ?? 0) + count;
      }
    }

    outDegreeValues.addAll(outDegree.values);
    inDegreeValues.addAll(inDegree.values);

    final giniOutDegree = calculateGiniCoefficient(outDegreeValues);
    final giniInDegree = calculateGiniCoefficient(inDegreeValues);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Participation Equity (Gini Coefficient)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Gini for Out-degree (Speaking): ${giniOutDegree.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          'Gini for In-degree (Listening): ${giniInDegree.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 4),
        Text(
          '(0 = perfect equality, 1 = perfect inequality)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
