import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:chat_analyzer_ui/ui/chat/chat_message.dart';
import 'package:chat_analyzer_ui/src/models/chat_message.dart';

void main() {
  group('ChatMessageWidget', () {
    testWidgets('muestra el contenido del mensaje y la hora', (tester) async {
      final message = ChatMessage(
        author: 'Alice',
        content: 'Hola 👋',
        dateTime: DateTime(2023, 5, 20, 14, 30),
        sentimentScore: 1.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageWidget(message: message, isMe: false),
          ),
        ),
      );

      // Verifica el contenido
      expect(find.text('Hola 👋'), findsOneWidget);

      // Verifica la hora formateada
      final formatted = DateFormat.jm().format(message.dateTime);
      expect(find.text(formatted), findsOneWidget);
    });

    testWidgets('muestra avatar a la izquierda cuando no es mío', (
      tester,
    ) async {
      final message = ChatMessage(
        author: 'Bob',
        content: 'Hey!',
        dateTime: DateTime.now(),
        sentimentScore: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageWidget(message: message, isMe: false),
          ),
        ),
      );

      // Row con avatar primero (izquierda)
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.start);
    });

    testWidgets('muestra avatar a la derecha cuando es mío', (tester) async {
      final message = ChatMessage(
        author: 'Yo',
        content: 'Mi mensaje',
        dateTime: DateTime.now(),
        sentimentScore: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ChatMessageWidget(message: message, isMe: true)),
        ),
      );

      // Row con avatar último (derecha)
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.end);
    });

    testWidgets('la barra de sentimiento usa verde si score > 0', (
      tester,
    ) async {
      final message = ChatMessage(
        author: 'Alice',
        content: 'Positivo',
        dateTime: DateTime.now(),
        sentimentScore: 2.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageWidget(message: message, isMe: false),
          ),
        ),
      );

      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.color, Colors.green);
    });

    testWidgets('la barra de sentimiento usa rojo si score < 0', (
      tester,
    ) async {
      final message = ChatMessage(
        author: 'Alice',
        content: 'Negativo',
        dateTime: DateTime.now(),
        sentimentScore: -1.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageWidget(message: message, isMe: false),
          ),
        ),
      );

      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.color, Colors.red);
    });

    testWidgets('la barra de sentimiento usa gris si score == 0', (
      tester,
    ) async {
      final message = ChatMessage(
        author: 'Alice',
        content: 'Neutral',
        dateTime: DateTime.now(),
        sentimentScore: 0.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageWidget(message: message, isMe: false),
          ),
        ),
      );

      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.color, Colors.grey);
    });
  });
}
