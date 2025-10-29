import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';

class ChatDateSelector extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime selected;
  final ValueChanged<DateTime?> onChanged;

  const ChatDateSelector({
    super.key,
    required this.dates,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    if (dates.isEmpty) return Text(appLocalizations.chat_date_selector_full_chat);

    return DropdownButton<DateTime>(
      value: selected,
      items: dates.map((date) {
        return DropdownMenuItem(
          value: date,
          child: Text(DateFormat.yMMMd().format(date)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
