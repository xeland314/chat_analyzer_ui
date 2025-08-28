
class ChatMessage {
  final String author;
  final String content;
  final DateTime dateTime;
  final double sentimentScore;

  ChatMessage({
    required this.author,
    required this.content,
    required this.dateTime,
    required this.sentimentScore,
  });
}
