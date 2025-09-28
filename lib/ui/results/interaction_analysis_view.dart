import 'package:chat_analyzer_ui/src/analysis/matrix_operations.dart';
import 'package:chat_analyzer_ui/ui/results/communication_graph_view.dart';
import 'package:chat_analyzer_ui/ui/results/reciprocity_heatmap_view.dart';
import 'package:chat_analyzer_ui/ui/results/participation_equity_view.dart';
import 'package:chat_analyzer_ui/ui/results/emitter_similarity_view.dart';
import 'package:chat_analyzer_ui/ui/results/receiver_similarity_view.dart';
import 'package:chat_analyzer_ui/ui/results/broker_detection_view.dart';
import 'package:chat_analyzer_ui/ui/results/composite_affinity_view.dart';
import 'package:chat_analyzer_ui/ui/results/markov_chain_view.dart';
import 'package:chat_analyzer_ui/ui/results/matrix_squared_view.dart';
import 'package:chat_analyzer_ui/ui/results/pagerank_view.dart';
import 'package:flutter/material.dart';
import '../../src/models/chat_analysis.dart';
import 'reciprocity_index.dart';
import 'reply_matrix_table.dart';
import 'response_time_chart.dart';
import 'starters_enders_view.dart';
import 'treshold_slider.dart';

/// Muestra los resultados del análisis de interacción.
///
/// Aún es Stateful para gestionar el umbral, pero ahora su build()
/// es mucho más limpio al delegar la creación de los gráficos.
class InteractionAnalysisView extends StatefulWidget {
  final ChatAnalysis analysis;
  const InteractionAnalysisView({super.key, required this.analysis});

  @override
  State<InteractionAnalysisView> createState() =>
      _InteractionAnalysisViewState();
}

class _InteractionAnalysisViewState extends State<InteractionAnalysisView> {
  late double _currentThreshold;
  late double _naturalThreshold;

  @override
  void initState() {
    super.initState();
    _naturalThreshold = widget.analysis.interactionAnalyzer
        .estimateNaturalThreshold();
    _currentThreshold = _naturalThreshold;
  }

  @override
  Widget build(BuildContext context) {
    final conversations = widget.analysis.interactionAnalyzer
        .segmentConversations(thresholdInMinutes: _currentThreshold);
    final starters = widget.analysis.interactionAnalyzer
        .calculateConversationStarters(conversations);
    final enders = widget.analysis.interactionAnalyzer
        .calculateConversationEnders(conversations);
    final metrics = widget.analysis.interactionAnalyzer
        .calculateInteractionMetrics(thresholdInMinutes: _currentThreshold);
    final responseTimes = metrics.averageResponseTime;
    final replies = metrics.whoRepliesToWhom;
    final matrixSquared = squareMatrix(replies);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interaction Analysis',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(),
            ThresholdSlider(
              naturalThreshold: _naturalThreshold,
              currentThreshold: _currentThreshold,
              onChanged: (value) {
                setState(() {
                  _currentThreshold = value;
                });
              },
            ),
            const SizedBox(height: 24),
            StartersEndersView(starters: starters, enders: enders),
            const SizedBox(height: 24),
            ResponseTimeChart(responseTimes: responseTimes),
            const SizedBox(height: 24),
            ReplyMatrixTable(replies: replies),
            const SizedBox(height: 24),
            ReciprocityIndex(replies: replies),
            const SizedBox(height: 24),
            PageRankView(replies: replies),
            const SizedBox(height: 24),
            MatrixSquaredView(replies: replies),
            const SizedBox(height: 24),
            CommunicationGraphView(replies: replies),
            const SizedBox(height: 24),
            MarkovChainView(replies: replies),
            const SizedBox(height: 24),
            ReciprocityHeatmapView(replies: replies),
            const SizedBox(height: 24),
            CompositeAffinityView(replies: replies, matrixSquared: matrixSquared),
            const SizedBox(height: 24),
            BrokerDetectionView(replies: replies),
            const SizedBox(height: 24),
            EmitterSimilarityView(replies: replies),
            const SizedBox(height: 24),
            ReceiverSimilarityView(replies: replies),
            const SizedBox(height: 24),
            ParticipationEquityView(replies: replies),
          ],
        ),
      ),
    );
  }
}
