import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chat_analyzer_ui/ui/chat/chat_message_list.dart';
import 'package:chat_analyzer_ui/ui/chat/chat_message.dart';
import 'package:chat_analyzer_ui/src/models/chat_message.dart';
import 'package:chat_analyzer_ui/l10n/app_localizations.dart';

void main() {
  group('ChatMessageList', () {
    testWidgets('muestra mensaje vacío cuando no hay mensajes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          // 1. Proporcionar las delegadas de localización
          localizationsDelegates: [
            AppLocalizations.delegate, // Tu delegado
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // 2. Definir los idiomas soportados (para que el delegado sepa qué cargar)
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('es'),
          home: Scaffold(
            body: ChatMessageList(messages: [], firstParticipantName: 'Alice'),
          ),
        ),
      );
      // 🚨 Paso clave: Obtener el contexto después de pumpWidget()
      final context = tester.element(find.byType(ChatMessageList));
      expect(
        find.text(AppLocalizations.of(context)!.chat_message_list_no_messages),
        findsOneWidget,
      );
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
          // 1. Proporcionar las delegadas de localización
          localizationsDelegates: [
            AppLocalizations.delegate, // Tu delegado
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // 2. Definir los idiomas soportados (para que el delegado sepa qué cargar)
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('es'),
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
