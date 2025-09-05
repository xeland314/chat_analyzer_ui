import 'package:flutter/material.dart';
import '../../src/models/chat_analysis.dart';
import '../results/analysis_result_view.dart';
import 'initial_view.dart';
import 'loading_view.dart';

// --- AnalysisView (El componente que maneja las 3 vistas) ---

class AnalysisView extends StatelessWidget {
  final bool isLoading;
  final ChatAnalysis? analysis;
  final VoidCallback onFilePick;

  const AnalysisView({
    super.key,
    required this.isLoading,
    required this.analysis,
    required this.onFilePick,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingView();
    } else if (analysis != null) {
      return AnalysisResultView(analysis: analysis!);
    } else {
      return InitialView(onFilePick: onFilePick);
    }
  }
}
