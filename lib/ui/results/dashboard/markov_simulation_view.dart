import 'dart:math';
import 'package:flutter/material.dart';
import '../../chat/chat_avatar.dart';
import '../../common/emoji_rich_text.dart';

class MarkovSimulationView extends StatefulWidget {
  final Map<String, Map<String, double>> transitionMatrix;

  const MarkovSimulationView({super.key, required this.transitionMatrix});

  @override
  State<MarkovSimulationView> createState() => _MarkovSimulationViewState();
}

class _MarkovSimulationViewState extends State<MarkovSimulationView> {
  String? _selectedSpeaker;
  int _simulationLength = 5;
  String? _simulationResult;

  @override
  void initState() {
    super.initState();
    if (widget.transitionMatrix.isNotEmpty) {
      _selectedSpeaker = widget.transitionMatrix.keys.first;
      WidgetsBinding.instance.addPostFrameCallback((_) => _runSimulation());
    }
  }

  void _runSimulation() {
    if (_selectedSpeaker == null) return;

    final random = Random();
    String currentSpeaker = _selectedSpeaker!;
    final conversation = [currentSpeaker];

    for (int i = 0; i < _simulationLength; i++) {
      final nextSpeakerProbabilities = widget.transitionMatrix[currentSpeaker];
      if (nextSpeakerProbabilities == null ||
          nextSpeakerProbabilities.isEmpty) {
        break;
      }

      final randomValue = random.nextDouble();
      double cumulativeProbability = 0;
      String? nextSpeaker;

      for (final entry in nextSpeakerProbabilities.entries) {
        cumulativeProbability += entry.value;
        if (randomValue <= cumulativeProbability) {
          nextSpeaker = entry.key;
          break;
        }
      }

      if (nextSpeaker != null) {
        conversation.add(nextSpeaker);
        currentSpeaker = nextSpeaker;
      } else {
        break;
      }
    }

    setState(() {
      _simulationResult = conversation.join(' → ');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Cabecera de la simulación
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _runSimulation,
                  child: emojiRichText(
                    "🔮 Simular conversación",
                    baseStyle: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Longitud: $_simulationLength mensajes",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Slider(
                  value: _simulationLength.toDouble(),
                  min: 5,
                  max: 50,
                  divisions: 9,
                  label: _simulationLength.toString(),
                  onChanged: (double value) {
                    setState(() {
                      _simulationLength = (value / 5).round() * 5;
                      _runSimulation();
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Resultado de la simulación
            if (_simulationResult != null)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _simulationResult!
                    .split(' → ')
                    .asMap()
                    .entries
                    .map(
                      (entry) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          authorAvatar(entry.value),
                          if (entry.key <
                              _simulationResult!.split(' → ').length - 1)
                            const Text(
                              ' → ',
                              style: TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                    )
                    .toList(),
              )
            else
              const Text(
                "Aún no hay simulación generada",
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
