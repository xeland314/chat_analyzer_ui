import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../chat/chat_avatar.dart';

class MarkovChainDashboardView extends StatefulWidget {
  final Map<String, Map<String, double>> transitionMatrix;

  const MarkovChainDashboardView({super.key, required this.transitionMatrix});

  @override
  State<MarkovChainDashboardView> createState() =>
      _MarkovChainDashboardViewState();
}

class _MarkovChainDashboardViewState extends State<MarkovChainDashboardView> {
  String? _selectedSpeaker;
  List<MapEntry<String, double>> _nextSpeakers = [];
  List<MapEntry<String, MapEntry<String, double>>> _topTransitions = [];
  int _topTransitionsCount = 3;
  int _simulationLength = 5;
  String? _simulationResult;

  @override
  void initState() {
    super.initState();
    if (widget.transitionMatrix.isNotEmpty) {
      _selectedSpeaker = widget.transitionMatrix.keys.first;
      _updateNextSpeakers();
      _updateTopTransitions();
      // **Nuevo: Ejecutar la simulación inicial**
      WidgetsBinding.instance.addPostFrameCallback((_) => _runSimulation());
    }
  }

  void _updateNextSpeakers() {
    if (_selectedSpeaker != null) {
      final speakers = widget.transitionMatrix[_selectedSpeaker]!.entries
          .toList();
      speakers.sort((a, b) => b.value.compareTo(a.value));
      setState(() {
        _nextSpeakers = speakers;
      });
    }
  }

  void _updateTopTransitions() {
    final transitions = <MapEntry<String, MapEntry<String, double>>>[];
    widget.transitionMatrix.forEach((from, toMap) {
      toMap.forEach((to, value) {
        transitions.add(MapEntry(from, MapEntry(to, value)));
      });
    });
    transitions.sort((a, b) => b.value.value.compareTo(a.value.value));
    setState(() {
      _topTransitions = transitions.take(_topTransitionsCount).toList();
    });
  }

  void _copyMatrixToClipboard() {
    final buffer = StringBuffer();
    final participants = widget.transitionMatrix.keys.toList()..sort();
    buffer.write('From \\ To\t');
    buffer.writeln(participants.join('\t'));
    for (final p1 in participants) {
      buffer.write('$p1\t');
      for (final p2 in participants) {
        final prob = widget.transitionMatrix[p1]?[p2] ?? 0;
        buffer.write('${prob.toStringAsFixed(2)}\t');
      }
      buffer.writeln();
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Matrix copied to clipboard')));
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
    final participants = widget.transitionMatrix.keys.toList()..sort();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'CADENA DE MARKOV - COMUNICACIÓN',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Seleccionar último hablante:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedSpeaker,
                  items: participants.map((speaker) {
                    return DropdownMenuItem(
                      value: speaker,
                      child: Text(speaker),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSpeaker = value;
                      _updateNextSpeakers();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Siguiente hablante',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._nextSpeakers.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    authorAvatar(entry.key),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: entry.value,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.withOpacity(entry.value),
                        ),
                      ),
                    ),
                    Text(' ${(entry.value * 100).toStringAsFixed(0)}%'),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🔍 TOP TRANSICIONES DEL GRUPO:'),
                DropdownButton<int>(
                  value: _topTransitionsCount,
                  items: [3, 5, 10].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(
                        value.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _topTransitionsCount = newValue;
                        _updateTopTransitions();
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),
            ..._topTransitions.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final from = entry.value.key;
              final to = entry.value.value.key;
              final value = entry.value.value.value;
              return Row(
                spacing: 8,
                children: [
                  Text('$index. '),
                  authorAvatar(from),
                  const Text(' → '),
                  authorAvatar(to),
                  Text(' (${(value * 100).toStringAsFixed(0)}%)'),
                ],
              );
            }),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _copyMatrixToClipboard,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copiar Matriz'),
                ),
                const SizedBox(width: 8),
                // **Nuevo Botón: Simular Nuevamente (más claro)**
                ElevatedButton.icon(
                  onPressed: _runSimulation,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Simular Nuevamente'),
                ),
              ],
            ),
            // **Nuevo: Controles de simulación usando Slider**
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Longitud de la Simulación:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_simulationLength pasos',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // El Slider permite el cambio inmediato de longitud
                  Slider(
                    value: _simulationLength.toDouble(),
                    min: 5,
                    max:
                        50, // Límite el máximo para evitar sobrecarga en la vista
                    divisions: 9, // Para tener saltos de 5, 10, 15...
                    label: _simulationLength.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        // Aseguramos que el valor es múltiplo de 5 para un control claro
                        _simulationLength = (value / 5).round() * 5;
                        // **Ejecutar simulación al cambiar la longitud**
                        _runSimulation();
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  // Resultados de la Simulación (Reutilizando la solución de Wrap)
                  if (_simulationResult != null)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: _simulationResult!
                          .split(' → ')
                          .asMap()
                          .entries
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  authorAvatar(entry.value),
                                  // Muestra la flecha si no es el último elemento
                                  if (entry.key <
                                      _simulationResult!.split(' → ').length -
                                          1)
                                    const Text(
                                      ' → ',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
