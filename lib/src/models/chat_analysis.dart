import '../analysis/interaction_analyzer.dart';
import 'chat_message.dart';
import 'chat_participant.dart';

class ChatAnalysis {
  final List<ChatParticipant> participants;
  final List<ChatMessage> allMessagesChronological;
  late final InteractionAnalyzer interactionAnalyzer;

  ChatAnalysis({List<ChatParticipant>? participants})
      : participants = participants ?? [],
        allMessagesChronological = _calculateAllMessages(participants ?? []) {
    interactionAnalyzer = InteractionAnalyzer(allMessagesChronological);
  }

  static List<ChatMessage> _calculateAllMessages(
      List<ChatParticipant> participants) {
    final allMessages = participants.expand((p) => p.messages).toList();
    allMessages.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return allMessages;
  }
  Map<String, dynamic> toMap() => {
        'participants': participants.map((p) => p.toMap()).toList(),
        'allMessagesChronological':
            allMessagesChronological.map((m) => m.toMap()).toList(),
      };
}
