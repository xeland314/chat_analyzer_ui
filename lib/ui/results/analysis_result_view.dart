import 'package:flutter/material.dart';
import '../../src/models/chat_analysis.dart';
import 'interaction_analysis_view.dart';
import 'participant_stats_view.dart';
import '../exports/export_button.dart';

// --- Resultados de Análisis de Chat ---
/// Vista principal que muestra todos los resultados del análisis.
///
/// Gestiona las opciones de visualización, como la cantidad de palabras a mostrar
/// y las palabras a ignorar, y pasa estos estados a los widgets secundarios.
class AnalysisResultView extends StatelessWidget {
  final ChatAnalysis analysis;
  final double displayCount;
  final Set<String> ignoredWords;
  final GlobalKey _analysisViewKey = GlobalKey();

  AnalysisResultView({
    super.key,
    required this.analysis,
    required this.displayCount,
    required this.ignoredWords,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RepaintBoundary(
        key: _analysisViewKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ...analysis.participants.map(
              (p) => ParticipantStatsView(
                participant: p,
                displayCount: displayCount.round(),
                ignoredWords: ignoredWords,
              ),
            ),
            const SizedBox(height: 16),
            InteractionAnalysisView(analysis: analysis),
          ],
        ),
      ),
      floatingActionButton: ExportButton(
        repaintBoundaryKey: _analysisViewKey,
        fileName: 'chat_analysis_report',
      ),
    );
  }
}
