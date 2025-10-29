import 'package:flutter/material.dart';
import '../common/emoji_rich_text.dart';
import '../../l10n/app_localizations.dart';

/// Vista que muestra una lista de frecuencia de palabras o emojis.
class FrequencyListView extends StatelessWidget {
  final String title;
  final List<MapEntry<String, int>> data;

  const FrequencyListView({super.key, required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (data.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(appLocalizations.frequency_list_view_no_data),
          )
        else
          ...data.map(
            (entry) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: emojiRichText(
                entry.key,
                baseStyle: const TextStyle(fontSize: 18),
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
