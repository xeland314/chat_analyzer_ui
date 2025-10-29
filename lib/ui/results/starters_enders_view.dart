import 'package:flutter/material.dart';
import '../chat/chat_avatar.dart';
import '../../l10n/app_localizations.dart';

class StartersEndersView extends StatelessWidget {
  final Map<String, int> starters;
  final Map<String, int> enders;

  const StartersEndersView({
    super.key,
    required this.starters,
    required this.enders,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final sortedStarters = starters.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sortedEnders = enders.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedStarters.isEmpty && sortedEnders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.starters_enders_view_title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildChart(context, appLocalizations.starters_enders_view_starters_title, sortedStarters, Colors.teal),
        const SizedBox(height: 16),
        _buildChart(context, appLocalizations.starters_enders_view_enders_title, sortedEnders, Colors.teal),
      ],
    );
  }

  Widget _buildChart(
    BuildContext context,
    String title,
    List<MapEntry<String, int>> participants,
    Color color,
  ) {
    if (participants.isEmpty) return const SizedBox.shrink();

    final maxValue = participants
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...participants.map((entry) {
          final proportion = maxValue > 0 ? entry.value / maxValue : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                SizedBox(width: 50, child: authorAvatar(entry.key)),
                const SizedBox(width: 8),
                Expanded(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: proportion,
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.value}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
