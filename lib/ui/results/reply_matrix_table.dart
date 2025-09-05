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
                      baseStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Noto Color Emoji',
                      ),
                    ),
                  ),
                ),
              ],
              rows: participants.map((replier) {
                return DataRow(
                  cells: [
                    DataCell(
                      emojiRichText(
                        replier,
                        baseStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Noto Color Emoji',
                        ),
                      ),
                    ),
                    ...participants.map((repliee) {
                      final count = replies[replier]?[repliee] ?? 0;
                      return DataCell(Text(count.toString()));
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
