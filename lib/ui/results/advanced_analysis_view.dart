import 'package:flutter/material.dart';
import '../../src/models/chat_analysis.dart';
import 'participant_stats_view.dart';
import 'reply_matrix_table.dart';
import 'response_time_chart.dart';
import 'starters_enders_view.dart';

class AdvancedAnalysisView extends StatelessWidget {
  final ChatAnalysis analysis;
  final double displayCount;
  final Set<String> ignoredWords;

  const AdvancedAnalysisView({
    super.key,
    required this.analysis,
    required this.displayCount,
    required this.ignoredWords,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = analysis.interactionAnalyzer.calculateInteractionMetrics();
    final replies = metrics.whoRepliesToWhom;
    final conversations = analysis.interactionAnalyzer.segmentConversations();
    final starters = analysis.interactionAnalyzer.calculateConversationStarters(
      conversations,
    );
    final enders = analysis.interactionAnalyzer.calculateConversationEnders(
      conversations,
    );
    final responseTimes = metrics.averageResponseTime;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Interaction Analysis',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(),
            ...analysis.participants.map(
              (p) => ParticipantStatsView(
                participant: p,
                displayCount: displayCount.round(),
                ignoredWords: ignoredWords,
              ),
            ),
            const SizedBox(height: 24),
            ReplyMatrixTable(replies: replies),
            const SizedBox(height: 24),
            StartersEndersView(starters: starters, enders: enders),
            const SizedBox(height: 24),
            ResponseTimeChart(responseTimes: responseTimes),
          ],
        ),
      ),
    );
  }
}
