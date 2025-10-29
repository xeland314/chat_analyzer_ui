import 'package:flutter/material.dart';
import '../../../src/analysis/pagerank.dart';
import '../../chat/chat_avatar.dart';
import '../../../l10n/app_localizations.dart';

class InfluencePodium extends StatelessWidget {
  final Map<String, Map<String, int>> replies;

  const InfluencePodium({super.key, required this.replies});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final pageRanks = calculateWeightedPageRank(replies);
    final sortedRanks = pageRanks.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topThree = sortedRanks.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(appLocalizations.influence_podium_title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (topThree.length > 1) _buildPodiumStep(topThree[1], 2, 100),
            if (topThree.isNotEmpty) _buildPodiumStep(topThree[0], 1, 120),
            if (topThree.length > 2) _buildPodiumStep(topThree[2], 3, 80),
          ],
        ),
      ],
    );
  }

  Widget _buildPodiumStep(
    MapEntry<String, double> entry,
    int rank,
    double height,
  ) {
    return Column(
      children: [
        Text(
          rank.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        authorAvatar(entry.key),
        const SizedBox(height: 4),
        Text(
          entry.value.toStringAsFixed(3),
          style: const TextStyle(color: Colors.grey),
        ),
        Container(
          height: height,
          width: 60,
          color: Colors.teal.withOpacity(0.5),
        ),
      ],
    );
  }
}
