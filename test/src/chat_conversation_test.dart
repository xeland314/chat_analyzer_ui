import 'package:test/test.dart';
import 'package:chat_analyzer_ui/src/analysis/interaction_analyzer.dart';
import 'package:chat_analyzer_ui/src/models/chat_message.dart';
import 'dart:core'; // Para DateTime y Duration

// --- Función Auxiliar para Mockear Mensajes ---
ChatMessage mockMessage(String author, {required int minutesOffset}) {
  return ChatMessage(
    author: author,
    content: 'Test message from $author',
    // Usamos una base de tiempo fija para que los cálculos de duración sean determinísticos.
    dateTime: DateTime(
      2025,
      10,
      30,
      10,
      0,
      0,
    ).add(Duration(minutes: minutesOffset)),
    sentimentScore: 0.0,
  );
}
// ----------------------------------------------

void main() {
  group('Conversation Tests', () {
    final message1 = mockMessage('Alice', minutesOffset: 5); // 10:05
    final message2 = mockMessage('Bob', minutesOffset: 10); // 10:10
    final message3 = mockMessage('Alice', minutesOffset: 15); // 10:15

    // Una conversación con mensajes
    final conversationWithData = Conversation(
      messages: [message1, message2, message3],
    );

    // Una conversación vacía
    final emptyConversation = Conversation(messages: []);

    // ----------------------------------------------------
    // Tests para startTime / endTime
    // ----------------------------------------------------

    test('startTime debe devolver la fecha/hora del primer mensaje', () {
      expect(conversationWithData.startTime, equals(message1.dateTime));
    });

    test('endTime debe devolver la fecha/hora del último mensaje', () {
      expect(conversationWithData.endTime, equals(message3.dateTime));
    });

    test('startTime (Vacío) debe devolver null', () {
      expect(emptyConversation.startTime, isNull);
    });

    test('endTime (Vacío) debe devolver null', () {
      expect(emptyConversation.endTime, isNull);
    });

    // ----------------------------------------------------
    // Tests para duration
    // ----------------------------------------------------

    test('duration debe calcular la duración correcta entre inicio y fin', () {
      // 10:15 - 10:05 = 10 minutos
      final expectedDuration = Duration(minutes: 10);
      expect(conversationWithData.duration, equals(expectedDuration));
    });

    test('duration (Vacío) debe devolver Duration.zero', () {
      expect(emptyConversation.duration, equals(Duration.zero));
    });

    // ----------------------------------------------------
    // Tests para participants
    // ----------------------------------------------------

    test('participants debe devolver una lista de autores únicos', () {
      // Los participantes son Alice, Bob, Alice -> [Alice, Bob]
      final expectedParticipants = ['Alice', 'Bob'];

      // Comprobamos que contiene solo los esperados, ignorando el orden
      expect(
        conversationWithData.participants,
        containsAll(expectedParticipants),
      );
      expect(
        conversationWithData.participants.length,
        equals(expectedParticipants.length),
      );
    });

    test('participants (Vacío) debe devolver una lista vacía', () {
      expect(emptyConversation.participants, isEmpty);
    });
  });
}
