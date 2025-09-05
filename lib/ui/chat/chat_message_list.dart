import 'package:flutter/material.dart';
import 'chat_message.dart';
import '../../src/models/chat_message.dart';

class ChatMessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final String firstParticipantName;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.firstParticipantName,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(child: Text('No messages on this date.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.author == firstParticipantName;
        return ChatMessageWidget(message: message, isMe: isMe);
      },
    );
  }
}
