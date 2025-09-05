import 'package:flutter/material.dart';
import '../../src/models/chat_analysis.dart';
import 'reply_matrix_table.dart';
import 'response_time_chart.dart';
import 'starters_enders_chart.dart';
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
            StartersEndersChart(starters: starters, enders: enders),
            const SizedBox(height: 24),
            ResponseTimeChart(responseTimes: responseTimes),
            const SizedBox(height: 24),
            ReplyMatrixTable(replies: replies),
          ],
        ),
      ),
    );
  }
}
