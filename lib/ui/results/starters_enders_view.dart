import 'package:flutter/material.dart';
import '../chat/chat_avatar.dart';

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
          'Conversation Starters & Enders',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildParticipantList('Starters', sortedStarters),
        const SizedBox(height: 16),
        _buildParticipantList('Enders', sortedEnders),
      ],
    );
  }

  Widget _buildParticipantList(
    String title,
    List<MapEntry<String, int>> participants,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  children: [
                    authorAvatar(participant.key),
                    const SizedBox(height: 4),
                    Text('${participant.value}'),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
