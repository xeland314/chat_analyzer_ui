import 'package:flutter/material.dart';
import '../common/info_wrapper.dart';
import '../../src/models/chat_analysis.dart';
import 'markov_chain_view.dart';
import 'reply_matrix_table.dart';
import '../../l10n/app_localizations.dart';

class AdvancedAnalysisView extends StatelessWidget {
  final ChatAnalysis analysis;

  const AdvancedAnalysisView({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
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
              appLocalizations.advanced_analysis_view_title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(),
            const SizedBox(height: 24),
            InfoWidgetWrapper(
              title: appLocalizations.advanced_analysis_view_reply_matrix_title,
              infoContent:
                  appLocalizations.advanced_analysis_view_reply_matrix_info,
              child: ReplyMatrixTable(replies: replies),
            ),
            const SizedBox(height: 24),
            InfoWidgetWrapper(
              title: appLocalizations.advanced_analysis_view_markov_chain_title,
              infoContent:
                  appLocalizations.advanced_analysis_view_markov_chain_info,
              child: MarkovChainView(replies: replies),
            ),
          ],
        ),
      ),
    );
  }
}
