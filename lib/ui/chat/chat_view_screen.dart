import 'package:flutter/material.dart';
import '../../src/models/chat_analysis.dart';
import '../../src/models/chat_message.dart';
import 'chat_message_list.dart';
import 'chat_helpers.dart';
import 'chat_date_selector.dart';

class ChatViewScreen extends StatefulWidget {
  final ChatAnalysis analysis;

  const ChatViewScreen({super.key, required this.analysis});

  @override
  State<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends State<ChatViewScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _availableDates;
  late List<ChatMessage> _messagesToShow;
  late String _firstParticipantName;

  void _updateMessagesForDate(DateTime date) {
    final messagesByDate = groupMessagesByDate(
      widget.analysis.allMessagesChronological,
    );
    setState(() {
      _selectedDate = date;
      _messagesToShow = messagesByDate[_selectedDate] ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    final messagesByDate = groupMessagesByDate(
      widget.analysis.allMessagesChronological,
    );
    _availableDates = messagesByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    _firstParticipantName = widget.analysis.participants.first.name;

    if (_availableDates.isNotEmpty) {
      _updateMessagesForDate(_availableDates.first);
    } else {
      _messagesToShow = [];
    }
  }

  void _onDateChanged(DateTime? newDate) {
    if (newDate != null) _updateMessagesForDate(newDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ChatDateSelector(
          dates: _availableDates,
          selected: _selectedDate,
          onChanged: _onDateChanged,
        ),
      ),
      body: ChatMessageList(
        messages: _messagesToShow,
        firstParticipantName: _firstParticipantName,
      ),
    );
  }
}
