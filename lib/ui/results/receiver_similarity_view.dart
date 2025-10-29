import 'package:flutter/material.dart';
import '../../src/analysis/matrix_operations.dart';
import '../common/emoji_rich_text.dart';
import '../../l10n/app_localizations.dart';

class ReceiverSimilarityView extends StatelessWidget {
  final Map<String, Map<String, int>> replies;

  const ReceiverSimilarityView({super.key, required this.replies});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final similarityMatrix = calculateCosineSimilarityMatrix(replies, false);
    final participants = similarityMatrix.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          appLocalizations.receiver_similarity_view_title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text(appLocalizations.receiver_similarity_view_participant_participant)),
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
                    final similarity = similarityMatrix[p1]?[p2] ?? 0.0;
                    return DataCell(Text(similarity.toStringAsFixed(2)));
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
