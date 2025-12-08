import 'package:chat_analyzer_ui/src/analysis/emoji_regex.dart';
import '../analysis/stopwords.dart';
import 'chat_message.dart';

class ChatParticipant {
  final String name;
  final List<ChatMessage> messages;

  // Cache para evitar recalcular
  Map<String, int>? _wordFrequency;
  Map<String, int>? _emojiFrequency;
  int? _multimediaCount;
  Map<String, int>? _sentimentAnalysis;
  Map<DateTime, List<ChatMessage>>? _messagesByDate;
  Map<DateTime, int>? _messageCountPerDay;
  Map<int, int>? _messageCountByHour;
  Map<DateTime, double>? _sentimentScorePerDay;

  ChatParticipant({required this.name, List<ChatMessage>? messages})
    : messages = messages ?? [];

  int get messageCount => messages.length;

  Map<DateTime, List<ChatMessage>> get messagesByDate {
    if (_messagesByDate != null) return _messagesByDate!;

    final groupedMessages = <DateTime, List<ChatMessage>>{};
    for (final message in messages) {
      final date = DateTime(
        message.dateTime.year,
        message.dateTime.month,
        message.dateTime.day,
      );
      if (groupedMessages.containsKey(date)) {
        groupedMessages[date]!.add(message);
      } else {
        groupedMessages[date] = [message];
      }
    }
    _messagesByDate = groupedMessages;
    return groupedMessages;
  }

  Map<DateTime, int> get messageCountPerDay {
    if (_messageCountPerDay != null) return _messageCountPerDay!;
    _messageCountPerDay = messagesByDate.map(
      (date, messages) => MapEntry(date, messages.length),
    );
    return _messageCountPerDay!;
  }

  Map<int, int> get messageCountByHour {
    if (_messageCountByHour != null) return _messageCountByHour!;
    final counts = <int, int>{};
    for (final message in messages) {
      final hour = message.dateTime.hour;
      counts[hour] = (counts[hour] ?? 0) + 1;
    }
    _messageCountByHour = counts;
    return counts;
  }

  Map<DateTime, double> get sentimentScorePerDay {
    if (_sentimentScorePerDay != null) return _sentimentScorePerDay!;
    final dailyScores = <DateTime, double>{};
    messagesByDate.forEach((date, messagesOnDay) {
      if (messagesOnDay.isNotEmpty) {
        final totalScore = messagesOnDay.fold(
          0.0,
          (sum, msg) => sum + msg.sentimentScore,
        );
        dailyScores[date] = totalScore / messagesOnDay.length;
      } else {
        dailyScores[date] = 0.0;
      }
    });
    _sentimentScorePerDay = dailyScores;
    return dailyScores;
  }

  int get multimediaCount {
    if (_multimediaCount != null) return _multimediaCount!;

    int count = 0;
    for (final message in messages) {
      if (mediaOmittedWords.contains(message.content.trim().toLowerCase())) {
        count++;
      }
    }
    _multimediaCount = count;
    return count;
  }

  Map<String, int> get sentimentAnalysis {
    if (_sentimentAnalysis != null) return _sentimentAnalysis!;

    final analysis = {'Positive': 0, 'Negative': 0, 'Neutral': 0};
    for (final message in messages) {
      if (message.sentimentScore > 0) {
        analysis['Positive'] = analysis['Positive']! + 1;
      } else if (message.sentimentScore < 0) {
        analysis['Negative'] = analysis['Negative']! + 1;
      } else {
        analysis['Neutral'] = analysis['Neutral']! + 1;
      }
    }
    _sentimentAnalysis = analysis;
    return analysis;
  }

  /// Devuelve un mapa con la frecuencia de cada palabra usada por el participante.
  Map<String, int> get wordFrequency {
    if (_wordFrequency != null) return _wordFrequency!;

    final frequency = <String, int>{};
    final wordPattern = RegExp(r'^[a-záéíóúüñ]+', caseSensitive: false);

    for (final message in messages) {
      final trimmedContent = message.content.trim().toLowerCase();
      if (mediaOmittedWords.contains(trimmedContent)) {
        continue; // No contar palabras de mensajes multimedia
      }

      // Simple tokenization
      final words = message.content.toLowerCase().split(RegExp(r'\s+'));

      for (String word in words) {
        // 🚨 Corrección: Limpiar la puntuación de la palabra aquí
        word = word.replaceAll(RegExp(r'[^\w\sáéíóúüñ]'), '').trim();
        // La expresión regular '[^\w\sáéíóúüñ]' elimina cualquier cosa que no sea:
        // una letra (a-z, A-Z, 0-9, _) o un espacio o una tilde/ñ.

        if (word.isEmpty) {
          continue;
        }

        if (!stopwords.contains(word) && wordPattern.hasMatch(word)) {
          frequency[word] = (frequency[word] ?? 0) + 1;
        }
      }
    }
    _wordFrequency = frequency;
    return frequency;
  }

  /// Devuelve un mapa con la frecuencia de cada emoji usado por el participante.
  Map<String, int> get emojiFrequency {
    if (_emojiFrequency != null) return _emojiFrequency!;

    final frequency = <String, int>{};
    for (final message in messages) {
      // Usa el paquete emoji_extension para extraer emojis de forma fiable.
      final emojis = EmojiRegex.extract(message.content);
      for (final emoji in emojis) {
        frequency[emoji] = (frequency[emoji] ?? 0) + 1;
      }
    }
    _emojiFrequency = frequency;
    return frequency;
  }

  /// Devuelve una lista con las [count] palabras más comunes.
  List<MapEntry<String, int>> getMostCommonWords(int count) {
    final sortedWords = wordFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedWords.take(count).toList();
  }

  /// Devuelve una lista con los [count] emojis más comunes.
  List<MapEntry<String, int>> getMostCommonEmojis(int count) {
    final sortedEmojis = emojiFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEmojis.take(count).toList();
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'messageCount': messageCount,
        'multimediaCount': multimediaCount,
        'messages': messages.map((m) => m.toMap()).toList(),
        'wordFrequency': wordFrequency,
        'emojiFrequency': emojiFrequency,
        'sentimentAnalysis': sentimentAnalysis,
        // Activity by hour: array of 24 integers, index = hour (0-23)
        'messages_by_hour': List<int>.generate(24, (i) => messageCountByHour[i] ?? 0),
        // Peak hour (0-23) where the participant sent the most messages
        'peak_hour': (() {
          if (messageCountByHour.isEmpty) return 0;
          int maxHour = 0;
          int maxCount = -1;
          messageCountByHour.forEach((hour, cnt) {
            if (cnt > maxCount) {
              maxCount = cnt;
              maxHour = hour;
            }
          });
          return maxHour;
        })(),
      };
}
