import 'package:flutter/material.dart';
import '../common/info_wrapper.dart';
import '../../src/models/chat_analysis.dart';
import 'markov_chain_view.dart';
import 'reply_matrix_table.dart';

class AdvancedAnalysisView extends StatelessWidget {
  final ChatAnalysis analysis;

  const AdvancedAnalysisView({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final metrics = analysis.interactionAnalyzer.calculateInteractionMetrics();
    final replies = metrics.whoRepliesToWhom;

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
            const SizedBox(height: 24),
            InfoWidgetWrapper(
              title: 'Reply Matrix',
              infoContent:
                  'This table shows the number of replies each participant received from others.',
              child: ReplyMatrixTable(replies: replies),
            ),
            const SizedBox(height: 24),
            InfoWidgetWrapper(
              title: 'Markov Chain',
              infoContent:
                  'This table shows the probability of a participant replying to another participant.',
              child: MarkovChainView(replies: replies),
            ),
          ],
        ),
      ),
    );
  }
}
