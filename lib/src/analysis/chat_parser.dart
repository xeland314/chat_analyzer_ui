import 'package:dart_sentiment/dart_sentiment.dart';
import 'package:intl/intl.dart';
import '../../src/models/chat_analysis.dart';
import '../../src/models/chat_message.dart';
import '../../src/models/chat_participant.dart';

class ChatParser {
  final _sentiment = Sentiment();

  // Formato: 1/1/22, 00:00 - Autor: Mensaje
  // Este RegExp es más estricto, anclado al inicio de la línea.
  final _linePattern = RegExp(
    r'^(\d{1,2}/\d{1,2}/\d{2,4}, \d{1,2}:\d{2}) - ([^:]+): (.+)',
  );

  // Lista de patrones de mensajes de sistema para ignorar.
  final _systemMessagePatterns = [
    RegExp(r'los mensajes y llamadas están cifrados'),
    RegExp(r'<Multimedia omitido>'),
    RegExp(r'cambió su número de teléfono'),
    RegExp(r'creó el grupo'),
  ];

  ChatAnalysis parse(String content) {
    final participants = <String, ChatParticipant>{};
    final lines = content.split('\n');

    String? currentAuthor;
    DateTime? currentDateTime;
    final messageBuffer = StringBuffer();

    void savePreviousMessage() {
      if (currentAuthor != null &&
          currentDateTime != null &&
          messageBuffer.isNotEmpty) {
        final messageContent = messageBuffer.toString().trim();
        final sentimentResult = _sentiment.analysis(
          messageContent,
          emoji: true,
          languageCode: LanguageCode.spanish,
        );

        final message = ChatMessage(
          author: currentAuthor,
          content: messageContent,
          dateTime: currentDateTime,
          sentimentScore: (sentimentResult['score'] as num).toDouble(),
        );

        if (!participants.containsKey(currentAuthor)) {
          participants[currentAuthor] = ChatParticipant(name: currentAuthor);
        }
        participants[currentAuthor]!.messages.add(message);
      }
    }

    for (final line in lines) {
      final match = _linePattern.firstMatch(line);

      if (match != null) {
        // Es una nueva linea de mensaje, guardar la anterior.
        savePreviousMessage();

        // Empezar a procesar la nueva linea.
        messageBuffer.clear();
        final dateTimeStr = match.group(1);
        final authorName = match.group(2);
        final messageContent = match.group(3);

        if (dateTimeStr != null &&
            authorName != null &&
            messageContent != null) {
          try {
            // Soporta formatos de año con 2 o 4 dígitos
            final format = dateTimeStr.contains(RegExp(r'/\d{4},'))
                ? DateFormat('d/M/yyyy, HH:mm')
                : DateFormat('d/M/yy, HH:mm');
            currentDateTime = format.parse(dateTimeStr);
            currentAuthor = authorName;
            messageBuffer.write(messageContent);
          } catch (e) {
            // Si falla el parseo, se trata como una linea multilínea del mensaje anterior.
            messageBuffer.write('\n$line');
          }
        }
      } else {
        // No es una nueva línea de mensaje. Puede ser una continuación o un mensaje de sistema.

        // Comprobar si es un mensaje de sistema para ignorarlo.
        bool isSystemMessage = _systemMessagePatterns.any(
          (pattern) => pattern.hasMatch(line),
        );

        if (!isSystemMessage && messageBuffer.isNotEmpty) {
          // Es una continuación del mensaje anterior.
          messageBuffer.write('\n$line');
        }
        // Si es un mensaje de sistema o no hay un mensaje anterior al que anexarlo, se ignora la línea.
      }
    }

    // Guardar el ultimo mensaje del buffer
    savePreviousMessage();

    return ChatAnalysis(participants: participants.values.toList());
  }
}
