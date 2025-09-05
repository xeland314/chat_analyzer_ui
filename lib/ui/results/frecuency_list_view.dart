import 'package:flutter/material.dart';
import '../common/emoji_rich_text.dart';

/// Vista que muestra una lista de frecuencia de palabras o emojis.
class FrequencyListView extends StatelessWidget {
  final String title;
  final List<MapEntry<String, int>> data;

  const FrequencyListView({super.key, required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (data.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('No data found.'),
          )
        else
          ...data.map(
            (entry) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: emojiRichText(
                entry.key,
                baseStyle: TextStyle(fontSize: 18),
              ),
              trailing: Text(
                entry.value.toString(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
      ],
    );
  }
}
