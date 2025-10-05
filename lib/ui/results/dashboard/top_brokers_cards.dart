import 'package:flutter/material.dart';
import '../../../src/analysis/betweenness_centrality.dart';
import '../../chat/chat_avatar.dart';

class TopBrokersCards extends StatelessWidget {
  final Map<String, Map<String, int>> replies;

  const TopBrokersCards({super.key, required this.replies});

  Map<String, double> _calculateBrokerScores() {
    // La función calculateBetweennessCentrality() devuelve un mapa de String -> double
    final scores = calculateBetweennessCentrality(replies);
    debugPrint('Broker Scores: $scores'); // Mantener para depuración

    return scores;
  }

  @override
  Widget build(BuildContext context) {
    final brokerScores = _calculateBrokerScores();

    // 1. Verificar si todos los puntajes son cero
    final hasBrokers = brokerScores.values.any((score) => score > 0.001);

    final sortedBrokers = brokerScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Seleccionar solo los brokers con puntaje > 0, o los 3 primeros si hay alguno
    final topBrokers = sortedBrokers
        .where((broker) => broker.value > 0.001)
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Brokers', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        if (hasBrokers) ...[
          // Muestra las tarjetas de los Top Brokers
          ...topBrokers.map((broker) => _buildBrokerCard(context, broker)),
        ] else
          // Muestra el mensaje si no hay brokers (todos los puntajes son ~0)
          _buildNoBrokersMessage(context),
      ],
    );
  }

  Widget _buildNoBrokersMessage(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey, size: 30),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'No se encontraron brokers significativos en esta conversación. '
                'Esto sugiere que la comunicación es lineal (A -> B -> C) o '
                'dispersa, sin un único "puente" crucial que conecte a otros pares de usuarios.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrokerCard(
    BuildContext context,
    MapEntry<String, double> broker,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            authorAvatar(broker.key),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    broker.key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Broker Score: ${broker.value.toStringAsFixed(3)}'),
                  const SizedBox(height: 4),
                  const Text(
                    'Este usuario actúa como un puente clave entre otros participantes.',
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
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
