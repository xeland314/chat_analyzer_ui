import 'package:dart_sentiment/dart_sentiment.dart';
import 'package:intl/intl.dart';
import '../../src/models/chat_analysis.dart';
import '../../src/models/chat_message.dart';
import '../../src/models/chat_participant.dart';

class ChatParserOptimized {
  final _sentiment = Sentiment();

  // OPTIMIZACIÓN 1: Compilar RegExp una sola vez (ya lo tenías bien)
  late final _linePattern = RegExp(
    r'^(\d{1,2}/\d{1,2}/\d{2,4}, \d{1,2}:\d{2}) - ([^:]+): (.+)',
  );

  // OPTIMIZACIÓN 2: Precompilar patrones de sistema
  late final _systemMessagePattern = RegExp(
    r'los mensajes y llamadas están cifrados|'
    r'<Multimedia omitido>|'
    r'cambió su número de teléfono|'
    r'creó el grupo',
  );

  // OPTIMIZACIÓN 3: Cachear DateFormat (crear DateFormat es COSTOSO)
  late final _dateFormat2Digits = DateFormat('d/M/yy, HH:mm');
  late final _dateFormat4Digits = DateFormat('d/M/yyyy, HH:mm');

  ChatAnalysis parse(String content) {
    // OPTIMIZACIÓN 4: Usar Map directamente, evitar búsquedas repetidas con containsKey
    final participants = <String, ChatParticipant>{};

    // OPTIMIZACIÓN 5: Dividir el string una sola vez
    final lines = content.split('\n');
    final totalLines = lines.length;

    // Variables de estado
    String? currentAuthor;
    DateTime? currentDateTime;
    final messageBuffer = StringBuffer();

    // OPTIMIZACIÓN 6: Función inline para guardar mensaje
    void savePreviousMessage() {
      if (currentAuthor != null &&
          currentDateTime != null &&
          messageBuffer.isNotEmpty) {
        final messageContent = messageBuffer.toString();

        // OPTIMIZACIÓN 7: Análisis de sentimiento más eficiente
        // Considera cachear o hacer batch processing si es posible
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

        // OPTIMIZACIÓN 8: putIfAbsent evita doble lookup
        final participant = participants.putIfAbsent(
          currentAuthor,
          () => ChatParticipant(name: currentAuthor!),
        );
        participant.messages.add(message);
      }
    }

    // OPTIMIZACIÓN 9: Iterar con índice en vez de foreach
    // (ligeramente más rápido en listas grandes)
    for (var i = 0; i < totalLines; i++) {
      final line = lines[i];

      // OPTIMIZACIÓN 10: Filtro rápido antes de regex costoso
      // Verificar si tiene el formato básico antes de aplicar regex
      if (line.length > 20 && line.contains(' - ') && line.contains(': ')) {
        final match = _linePattern.firstMatch(line);

        if (match != null) {
          // Nueva línea de mensaje
          savePreviousMessage();
          messageBuffer.clear();

          final dateTimeStr = match.group(1)!;
          final authorName = match.group(2)!;
          final messageContent = match.group(3)!;

          // OPTIMIZACIÓN 11: Cachear DateFormat según formato detectado
          try {
            // Detección rápida: buscar '/yyyy,' es más barato que regex
            currentDateTime = dateTimeStr.contains(RegExp(r'/\d{4},'))
                ? _dateFormat4Digits.parse(dateTimeStr)
                : _dateFormat2Digits.parse(dateTimeStr);

            currentAuthor = authorName;
            messageBuffer.write(messageContent);
          } catch (e) {
            // Si falla el parseo, tratar como continuación
            if (messageBuffer.isNotEmpty) {
              messageBuffer.write('\n');
              messageBuffer.write(line);
            }
          }
          continue; // Evitar chequeos adicionales
        }
      }

      // OPTIMIZACIÓN 12: Un solo regex para todos los patrones de sistema
      if (_systemMessagePattern.hasMatch(line)) {
        continue; // Ignorar mensaje de sistema
      }

      // Continuación de mensaje multilínea
      if (messageBuffer.isNotEmpty) {
        messageBuffer.write('\n');
        messageBuffer.write(line);
      }
    }

    // Guardar último mensaje
    savePreviousMessage();

    return ChatAnalysis(participants: participants.values.toList());
  }
}

// ============================================================================
// VERSIÓN ULTRA-OPTIMIZADA: Procesamiento por lotes de análisis de sentimiento
// ============================================================================

class ChatParserBatchOptimized {
  final _sentiment = Sentiment();

  late final _linePattern = RegExp(
    r'^(\d{1,2}/\d{1,2}/\d{2,4}, \d{1,2}:\d{2}) - ([^:]+): (.+)',
  );

  late final _systemMessagePattern = RegExp(
    r'los mensajes y llamadas están cifrados|'
    r'<Multimedia omitido>|'
    r'cambió su número de teléfono|'
    r'creó el grupo',
  );

  late final _dateFormat2Digits = DateFormat('d/M/yy, HH:mm');
  late final _dateFormat4Digits = DateFormat('d/M/yyyy, HH:mm');

  ChatAnalysis parse(String content) {
    final participants = <String, ChatParticipant>{};
    final lines = content.split('\n');

    String? currentAuthor;
    DateTime? currentDateTime;
    final messageBuffer = StringBuffer();

    // OPTIMIZACIÓN CLAVE: Acumular mensajes y hacer análisis de sentimiento al final
    final pendingMessages = <_PendingMessage>[];

    void savePreviousMessage() {
      if (currentAuthor != null &&
          currentDateTime != null &&
          messageBuffer.isNotEmpty) {
        final cleanContent = messageBuffer.toString().trimRight();
        pendingMessages.add(
          _PendingMessage(
            author: currentAuthor,
            content: cleanContent,
            dateTime: currentDateTime,
          ),
        );

        // Crear participante si no existe
        participants.putIfAbsent(
          currentAuthor,
          () => ChatParticipant(name: currentAuthor!),
        );
      }
    }

    // Fase 1: Parseo rápido sin análisis de sentimiento
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.length > 20 && line.contains(' - ') && line.contains(': ')) {
        final match = _linePattern.firstMatch(line);

        if (match != null) {
          savePreviousMessage();
          messageBuffer.clear();

          final dateTimeStr = match.group(1)!;
          final authorName = match.group(2)!;
          final messageContent = match.group(3)!;

          try {
            currentDateTime = dateTimeStr.contains(RegExp(r'/\d{4},'))
                ? _dateFormat4Digits.parse(dateTimeStr)
                : _dateFormat2Digits.parse(dateTimeStr);

            currentAuthor = authorName;
            messageBuffer.write(messageContent);
          } catch (e) {
            if (messageBuffer.isNotEmpty) {
              messageBuffer.write('\n$line');
            }
          }
          continue;
        }
      }

      if (_systemMessagePattern.hasMatch(line)) {
        continue;
      }

      if (messageBuffer.isNotEmpty) {
        messageBuffer.write('\n$line');
      }
    }

    savePreviousMessage();

    // Fase 2: Análisis de sentimiento en lote
    // (El cuello de botella principal es aquí)
    for (final pending in pendingMessages) {
      final sentimentResult = _sentiment.analysis(
        pending.content,
        emoji: true,
        languageCode: LanguageCode.spanish,
      );

      final message = ChatMessage(
        author: pending.author,
        content: pending.content,
        dateTime: pending.dateTime,
        sentimentScore: (sentimentResult['score'] as num).toDouble(),
      );

      participants[pending.author]!.messages.add(message);
    }

    return ChatAnalysis(participants: participants.values.toList());
  }
}

class _PendingMessage {
  final String author;
  final String content;
  final DateTime dateTime;

  _PendingMessage({
    required this.author,
    required this.content,
    required this.dateTime,
  });
}
