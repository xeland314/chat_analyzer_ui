import 'package:flutter/material.dart';
import '../../src/models/chat_analysis.dart';
import 'dashboard_view.dart';
import 'advanced_analysis_view.dart';
import '../exports/export_button.dart';

class AdvancedAnalysisPage extends StatelessWidget {
  final ChatAnalysis analysis;

  const AdvancedAnalysisPage({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Analysis')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [AdvancedAnalysisView(analysis: analysis)],
      ),
    );
  }
}

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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              DashboardView(
                analysis: analysis,
                displayCount: displayCount,
                ignoredWords: ignoredWords,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AdvancedAnalysisPage(analysis: analysis),
                    ),
                  );
                },
                child: const Text('View Advanced Analysis'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ExportButton(
        repaintBoundaryKey: _analysisViewKey,
        fileName: 'chat_analysis_report',
      ),
    );
  }
}
