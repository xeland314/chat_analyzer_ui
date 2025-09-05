import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_analyzer_ui/ui/chat/chat_message_list.dart';
import 'package:chat_analyzer_ui/ui/chat/chat_message.dart';
import 'package:chat_analyzer_ui/src/models/chat_message.dart';

void main() {
  group('ChatMessageList', () {
    testWidgets('muestra mensaje vacío cuando no hay mensajes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatMessageList(messages: [], firstParticipantName: 'Alice'),
          ),
        ),
      );

      expect(find.text('No messages on this date.'), findsOneWidget);
      expect(find.byType(ChatMessageWidget), findsNothing);
    });

    testWidgets('muestra lista de ChatMessageWidget cuando hay mensajes', (
      WidgetTester tester,
    ) async {
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
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageList(
              messages: messages,
              firstParticipantName: 'Alice',
            ),
          ),
        ),
      );

      expect(find.byType(ChatMessageWidget), findsNWidgets(2));
      expect(find.text('Hola'), findsOneWidget);
      expect(find.text('Hey'), findsOneWidget);
    });
  });
}
