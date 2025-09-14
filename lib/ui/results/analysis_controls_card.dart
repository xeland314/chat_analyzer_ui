import 'package:flutter/material.dart';

/// Tarjeta que contiene los controles para la pantalla de resultados.
///
/// Se ha extraído para mantener el código de la vista principal más limpio.
class AnalysisControlsCard extends StatelessWidget {
  final double displayCount;
  final ValueChanged<double> onDisplayCountChanged;
  final Set<String> ignoredWords;
  final VoidCallback onAddIgnoredWord;
  final ValueChanged<String> onRemoveIgnoredWord;
  final TextEditingController textController;
  final VoidCallback onViewChat;
  final VoidCallback onResetAnalysis;

  const AnalysisControlsCard({
    super.key,
    required this.displayCount,
    required this.onDisplayCountChanged,
    required this.ignoredWords,
    required this.onAddIgnoredWord,
    required this.onRemoveIgnoredWord,
    required this.textController,
    required this.onViewChat,
    required this.onResetAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Display Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: onViewChat,
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('View Full Chat'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: onResetAnalysis,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Analysis'),
            ),
            const SizedBox(height: 16),
            Text('Show Top: ${displayCount.round()}'),
            Slider(
              value: displayCount,
              min: 5,
              max: 30,
              divisions: 25,
              label: displayCount.round().toString(),
              onChanged: onDisplayCountChanged,
            ),
            const SizedBox(height: 16),
            Text('Ignore Words', style: Theme.of(context).textTheme.titleLarge),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: 'Word to ignore',
                    ),
                    onSubmitted: (_) => onAddIgnoredWord(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onAddIgnoredWord,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (ignoredWords.isNotEmpty)
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: ignoredWords.map((word) {
                  return Chip(
                    label: Text(word),
                    onDeleted: () => onRemoveIgnoredWord(word),
                  );
                }).toList(),
              )
            else
              const Text(
                'No words are being ignored.',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
