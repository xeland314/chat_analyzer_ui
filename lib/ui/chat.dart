import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../src/models/chat_analysis.dart';
import '../src/models/chat_message.dart';

// --- Unified Chat View Screen ---

String getInitials(String name) => name
    .trim()
    .split(RegExp(' + '))
    .map((s) => s[0])
    .take(2)
    .join()
    .toUpperCase();

Color colorForName(String name) {
  final hash = name.hashCode;

  // Color base desde el hash
  int r = (hash & 0xFF0000) >> 16;
  int g = (hash & 0x00FF00) >> 8;
  int b = hash & 0x0000FF;

  Color color = Color.fromRGBO(r, g, b, 1);

  // Función para calcular luminancia relativa (0=negro, 1=blanco)
  double luminance(Color c) {
    return (0.299 * c.r + 0.587 * c.g + 0.114 * c.b);
  }

  // Detectar si es "demasiado claro"
  bool isTooLight(Color c) => luminance(c) > 0.75;

  // Detectar si es cercano a amarillo (alto R y G, bajo B)
  bool isYellowish(Color c) =>
      ((c.r * 255.0).round() & 0xff) > 200 &&
      ((c.g * 255.0).round() & 0xff) > 200 &&
      ((c.b * 255.0).round() & 0xff) < 150;

  // Ajustar color si es muy claro o amarillento
  if (isTooLight(color) || isYellowish(color)) {
    // Convertimos a HSL para manipular tono y luminosidad
    final hsl = HSLColor.fromColor(color);

    // Si es claro, bajamos luminosidad; si es amarillo, giramos tono hacia otra gama
    double newHue = hsl.hue;
    if (isYellowish(color)) {
      newHue = (hsl.hue + 180) % 360; // rotar a color opuesto
    }

    color = hsl
        .withHue(newHue)
        .withLightness(min(hsl.lightness, 0.5))
        .withSaturation(max(hsl.saturation, 0.5))
        .toColor();
  }

  return color;
}

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

  @override
  void initState() {
    super.initState();
    final messagesByDate = _groupMessagesByDate(
      widget.analysis.allMessagesChronological,
    );
    _availableDates = messagesByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    _firstParticipantName = widget.analysis.participants.first.name;

    if (_availableDates.isNotEmpty) {
      _selectedDate = _availableDates.first;
      _messagesToShow = messagesByDate[_selectedDate] ?? [];
    } else {
      _messagesToShow = [];
    }
  }

  Map<DateTime, List<ChatMessage>> _groupMessagesByDate(
    List<ChatMessage> messages,
  ) {
    final groupedMessages = <DateTime, List<ChatMessage>>{};
    for (final message in messages) {
      final date = DateTime(
        message.dateTime.year,
        message.dateTime.month,
        message.dateTime.day,
      );
      if (groupedMessages.containsKey(date)) {
        groupedMessages[date]!.add(message);
      } else {
        groupedMessages[date] = [message];
      }
    }
    return groupedMessages;
  }

  void _onDateChanged(DateTime? newDate) {
    if (newDate != null) {
      setState(() {
        _selectedDate = newDate;
        final messagesByDate = _groupMessagesByDate(
          widget.analysis.allMessagesChronological,
        );
        _messagesToShow = messagesByDate[_selectedDate] ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _availableDates.isEmpty
            ? const Text('Full Chat')
            : DropdownButton<DateTime>(
                value: _selectedDate,
                items: _availableDates.map((date) {
                  return DropdownMenuItem(
                    value: date,
                    child: Text(DateFormat.yMMMd().format(date)),
                  );
                }).toList(),
                onChanged: _onDateChanged,
              ),
      ),
      body: _messagesToShow.isEmpty
          ? const Center(child: Text('No messages on this date.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messagesToShow.length,
              itemBuilder: (context, index) {
                final message = _messagesToShow[index];
                final isMe = message.author == _firstParticipantName;
                return ChatMessageWidget(message: message, isMe: isMe);
              },
            ),
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final authorColor = colorForName(message.author);
    final authorInitials = getInitials(message.author);

    final bubble = Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: const TextStyle(fontFamily: 'Noto Color Emoji'),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat.jm().format(message.dateTime),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: (message.sentimentScore + 5).clamp(0, 10) / 10,
              backgroundColor: Colors.white,
              color: message.sentimentScore > 0
                  ? Colors.green
                  : (message.sentimentScore < 0 ? Colors.red : Colors.grey),
            ),
          ],
        ),
      ),
    );

    final avatar = CircleAvatar(
      backgroundColor: authorColor,
      child: Text(
        authorInitials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) avatar,
          const SizedBox(width: 8),
          Flexible(child: bubble),
          const SizedBox(width: 8),
          if (isMe) avatar,
        ],
      ),
    );
  }
}
