import 'package:flutter/material.dart';
import '../common/emoji_rich_text.dart';
import '../../src/models/chat_participant.dart';
import 'frecuency_list_view.dart';
import 'temporal_analysis_view.dart';
import 'sentiment_bar_chart.dart';

/// Muestra estadísticas de un participante individual del chat.
///
/// Este widget ahora es más simple y delega la construcción de sus subsecciones
/// a widgets dedicados, mejorando la organización del código.
class ParticipantStatsView extends StatelessWidget {
  final ChatParticipant participant;
  final int displayCount;
  final Set<String> ignoredWords;

  const ParticipantStatsView({
    super.key,
    required this.participant,
    required this.displayCount,
    required this.ignoredWords,
  });

  @override
  Widget build(BuildContext context) {
    final filteredWordEntries =
        participant.wordFrequency.entries
            .where((entry) => !ignoredWords.contains(entry.key))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    final topWords = filteredWordEntries.take(displayCount).toList();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        title: emojiRichText(
          participant.name,
          baseStyle: TextStyle(
            fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${participant.messageCount} messages, ${participant.multimediaCount} multimedia files',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SentimentBarChart(sentimentData: participant.sentimentAnalysis),
                const SizedBox(height: 16),
                FrequencyListView(title: 'Most Common Words', data: topWords),
                const SizedBox(height: 16),
                FrequencyListView(
                  title: 'Most Common Emojis',
                  data: participant.getMostCommonEmojis(displayCount),
                ),
                TemporalAnalysisView(participant: participant),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
