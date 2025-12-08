
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

  Map<String, dynamic> toMap() => {
        'author': author,
        'content': content,
        'dateTime': dateTime.toIso8601String(),
        'sentimentScore': sentimentScore,
      };

  String toJson() => toMap().toString();
}
