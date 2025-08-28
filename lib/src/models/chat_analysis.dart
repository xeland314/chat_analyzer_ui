import 'chat_message.dart';
import 'chat_participant.dart';

class ChatAnalysis {
  final List<ChatParticipant> participants;

  // Cache
  List<ChatMessage>? _allMessagesChronological;

  ChatAnalysis({List<ChatParticipant>? participants})
      : participants = participants ?? [];

  /// Combina los mensajes de todos los participantes y los ordena por fecha.
  List<ChatMessage> get allMessagesChronological {
    if (_allMessagesChronological != null) return _allMessagesChronological!;

    final allMessages = participants.expand((p) => p.messages).toList();
    allMessages.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    _allMessagesChronological = allMessages;
    return allMessages;
  }
}
