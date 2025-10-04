import 'package:flutter/material.dart';
import '../../src/models/chat_analysis.dart';
import 'dashboard/equity_gauges.dart';
import 'dashboard/influence_podium.dart';
import 'dashboard/top_brokers_cards.dart';
import 'dashboard/key_relationships.dart';
import 'markov_chain_dashboard_view.dart';
import '../../src/analysis/matrix_operations.dart';
import 'dashboard/interactive_network_graph.dart';
import 'response_time_chart.dart';
import 'starters_enders_view.dart';

class DashboardView extends StatelessWidget {
  final ChatAnalysis analysis;

  const DashboardView({super.key, required this.analysis});

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dashboard', style: Theme.of(context).textTheme.headlineSmall),
        const Divider(),
        InteractiveNetworkGraph(replies: replies),
        const SizedBox(height: 24),
        EquityGauges(replies: replies),
        const SizedBox(height: 24),
        StartersEndersView(starters: starters, enders: enders),
        const SizedBox(height: 24),
        ResponseTimeChart(responseTimes: responseTimes),
        const SizedBox(height: 24),
        InfluencePodium(replies: replies),
        const SizedBox(height: 24),
        TopBrokersCards(replies: replies),
        const SizedBox(height: 24),
        KeyRelationships(replies: replies),
        const SizedBox(height: 24),
        MarkovChainDashboardView(
          transitionMatrix: normalizeMatrix(replies),
        ),
      ],
    );
  }
}
