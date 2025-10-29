import 'package:flutter/material.dart';
import '../../../src/analysis/betweenness_centrality.dart';
import '../../chat/chat_avatar.dart';
import '../../../l10n/app_localizations.dart';

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
    final appLocalizations = AppLocalizations.of(context)!;
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
        Text(appLocalizations.top_brokers_cards_title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        if (hasBrokers) ...[
          // Muestra las tarjetas de los Top Brokers
          ...topBrokers.map((broker) => _buildBrokerCard(context, broker, appLocalizations)),
        ] else
          // Muestra el mensaje si no hay brokers (todos los puntajes son ~0)
          _buildNoBrokersMessage(context, appLocalizations),
      ],
    );
  }

  Widget _buildNoBrokersMessage(BuildContext context, AppLocalizations appLocalizations) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.grey, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                appLocalizations.top_brokers_cards_no_brokers_message,
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
    AppLocalizations appLocalizations,
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
                  Text(appLocalizations.top_brokers_cards_broker_score(broker.value.toStringAsFixed(3))),
                  const SizedBox(height: 4),
                  Text(
                    appLocalizations.top_brokers_cards_broker_description,
                    style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
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
