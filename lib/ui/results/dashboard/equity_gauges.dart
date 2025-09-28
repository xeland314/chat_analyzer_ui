import 'package:flutter/material.dart';
import '../../../src/analysis/matrix_operations.dart';

class EquityGauges extends StatelessWidget {
  final Map<String, Map<String, int>> replies;

  const EquityGauges({super.key, required this.replies});

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
        Text(
          'Participation Equity',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        _buildGauge('Speaking Equity', giniOutDegree),
        const SizedBox(height: 8),
        _buildGauge('Listening Equity', giniInDegree),
        const SizedBox(height: 4),
        Text(
          '(0 = perfect equality, 1 = perfect inequality)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildGauge(String title, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 20,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: ColorTween(
                    begin: Colors.green,
                    end: Colors.red,
                  ).animate(AlwaysStoppedAnimation(value)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(value.toStringAsFixed(2)),
          ],
        ),
      ],
    );
  }
}
