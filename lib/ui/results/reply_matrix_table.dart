import 'package:flutter/material.dart';
import '../common/emoji_rich_text.dart';

/// Tabla que muestra quién le responde a quién.
class ReplyMatrixTable extends StatelessWidget {
  final Map<String, Map<String, int>> replies;

  const ReplyMatrixTable({super.key, required this.replies});

  @override
  Widget build(BuildContext context) {
    final participants = replies.keys.toList()..sort();
    if (participants.isEmpty) return const SizedBox.shrink();

    final scrollController = ScrollController();

    // Calculate degrees
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

    final balance = <String, int>{};
    for (final p in participants) {
      balance[p] = (outDegree[p] ?? 0) - (inDegree[p] ?? 0);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who Replies to Whom',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                const DataColumn(label: Text('Replier \\ To')),
                ...participants.map(
                  (p) => DataColumn(
                    label: emojiRichText(
                      p,
                      baseStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const DataColumn(label: Text('Out-degree (Replies Sent)')),
                const DataColumn(label: Text('Balance (Out - In)')),
              ],
              rows: [
                ...participants.map((replier) {
                  return DataRow(
                    cells: [
                      DataCell(
                        emojiRichText(
                          replier,
                          baseStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...participants.map((repliee) {
                        final count = replies[replier]?[repliee] ?? 0;
                        return DataCell(Text(count.toString()));
                      }),
                      DataCell(Text(outDegree[replier].toString())),
                      DataCell(Text(balance[replier].toString())),
                    ],
                  );
                }),
                DataRow(
                  cells: [
                    const DataCell(Text('In-degree (Replies Received)')),
                    ...participants.map((p) {
                      return DataCell(Text(inDegree[p].toString()));
                    }),
                    const DataCell(Text('')), // Empty cell for Out-degree
                    const DataCell(Text('')), // Empty cell for Balance
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
