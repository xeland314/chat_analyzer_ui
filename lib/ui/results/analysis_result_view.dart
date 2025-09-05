import 'package:flutter/material.dart';
import '../../src/models/chat_analysis.dart';
import '../chat/chat_view_screen.dart';
import 'interaction_analysis_view.dart';
import 'participant_stats_view.dart';
import 'analysis_controls_card.dart';

// --- Resultados de Análisis de Chat ---
/// Vista principal que muestra todos los resultados del análisis.
///
/// Gestiona las opciones de visualización, como la cantidad de palabras a mostrar
/// y las palabras a ignorar, y pasa estos estados a los widgets secundarios.
class AnalysisResultView extends StatefulWidget {
  final ChatAnalysis analysis;

  const AnalysisResultView({super.key, required this.analysis});

  @override
  State<AnalysisResultView> createState() => _AnalysisResultViewState();
}

class _AnalysisResultViewState extends State<AnalysisResultView> {
  double _displayCount = 5.0;
  final Set<String> _customIgnoredWords = {};
  final _textController = TextEditingController();

  void _addIgnoredWord() {
    final word = _textController.text.trim().toLowerCase();
    if (word.isNotEmpty) {
      setState(() {
        _customIgnoredWords.add(word);
      });
      _textController.clear();
    }
  }

  void _removeIgnoredWord(String word) {
    setState(() {
      _customIgnoredWords.remove(word);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        AnalysisControlsCard(
          displayCount: _displayCount,
          onDisplayCountChanged: (value) {
            setState(() {
              _displayCount = value;
            });
          },
          ignoredWords: _customIgnoredWords,
          onAddIgnoredWord: _addIgnoredWord,
          onRemoveIgnoredWord: _removeIgnoredWord,
          textController: _textController,
          onViewChat: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatViewScreen(analysis: widget.analysis),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        InteractionAnalysisView(analysis: widget.analysis),
        const SizedBox(height: 16),
        ...widget.analysis.participants.map(
          (p) => ParticipantStatsView(
            participant: p,
            displayCount: _displayCount.round(),
            ignoredWords: _customIgnoredWords,
          ),
        ),
      ],
    );
  }
}
