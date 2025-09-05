import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    if (dates.isEmpty) return const Text('Full Chat');

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
