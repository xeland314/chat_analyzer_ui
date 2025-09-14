import 'package:flutter/material.dart';
import '../../src/analysis/matrix_operations.dart';
import '../common/emoji_rich_text.dart';

class CompositeAffinityView extends StatelessWidget {
  final Map<String, Map<String, int>> replies;
  final Map<String, Map<String, int>> matrixSquared;

  const CompositeAffinityView({super.key, required this.replies, required this.matrixSquared});

  @override
  Widget build(BuildContext context) {
    // You can adjust alpha based on how much you want to weight direct vs indirect influence
    const double alpha = 0.7; 
    final compositeAffinity = calculateCompositeAffinity(replies, matrixSquared, alpha);
    final participants = compositeAffinity.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Composite Affinity (Direct + Indirect)',
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
                    final affinity = compositeAffinity[p1]?[p2] ?? 0.0;
                    return DataCell(Text(affinity.toStringAsFixed(2)));
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
