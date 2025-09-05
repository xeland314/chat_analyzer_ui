import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../src/models/chat_message.dart';
import '../common/emoji_rich_text.dart';
import 'chat_helpers.dart';
import 'chat_avatar.dart';

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
    final bubble = Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            emojiRichText(
              message.content,
              baseStyle: Theme.of(context).textTheme.bodyMedium,
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
              color: sentimentColor(message.sentimentScore),
            ),
          ],
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
          if (!isMe) authorAvatar(message.author),
          const SizedBox(width: 8),
          Flexible(child: bubble),
          const SizedBox(width: 8),
          if (isMe) authorAvatar(message.author),
        ],
      ),
    );
  }
}
