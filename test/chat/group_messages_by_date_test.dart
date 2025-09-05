import 'package:flutter_test/flutter_test.dart';
import 'package:chat_analyzer_ui/ui/chat/chat_helpers.dart';
import 'package:chat_analyzer_ui/src/models/chat_message.dart';

void main() {
  group('groupMessagesByDate', () {
    test('agrupa mensajes por fecha correctamente', () {
      final messages = [
        ChatMessage(
          author: 'Alice',
          content: 'Hola',
          dateTime: DateTime(2023, 5, 20, 10, 0),
          sentimentScore: 1.0,
        ),
        ChatMessage(
          author: 'Bob',
          content: 'Hey',
          dateTime: DateTime(2023, 5, 20, 15, 0),
          sentimentScore: -1.0,
        ),
        ChatMessage(
          author: 'Alice',
          content: 'Otro día',
          dateTime: DateTime(2023, 5, 21, 12, 0),
          sentimentScore: 0,
        ),
      ];

      final grouped = groupMessagesByDate(messages);

      expect(grouped.length, 2);
      expect(grouped[DateTime(2023, 5, 20)]!.length, 2);
      expect(grouped[DateTime(2023, 5, 21)]!.length, 1);
    });

    test('devuelve mapa vacío si no hay mensajes', () {
      final grouped = groupMessagesByDate([]);
      expect(grouped, isEmpty);
    });
  });
}
