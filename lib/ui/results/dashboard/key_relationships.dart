import 'package:flutter/material.dart';
import '../../chat/chat_avatar.dart';
import '../../../l10n/app_localizations.dart';

class KeyRelationships extends StatelessWidget {
  final Map<String, Map<String, int>> replies;

  const KeyRelationships({super.key, required this.replies});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final relationships = _calculateKeyRelationships(appLocalizations);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.key_relationships_title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...relationships.map((rel) => _buildRelationshipCard(rel, appLocalizations)),
      ],
    );
  }

  List<_Relationship> _calculateKeyRelationships(AppLocalizations appLocalizations) {
    final relationships = <_Relationship>[];
    final participants = replies.keys.toList();

    for (int i = 0; i < participants.length; i++) {
      for (int j = i + 1; j < participants.length; j++) {
        final p1 = participants[i];
        final p2 = participants[j];

        final p1_to_p2 = replies[p1]?[p2] ?? 0;
        final p2_to_p1 = replies[p2]?[p1] ?? 0;

        if (p1_to_p2 == 0 && p2_to_p1 == 0) continue;

        final total = p1_to_p2 + p2_to_p1;
        final reciprocity = (p1_to_p2 < p2_to_p1 ? p1_to_p2 : p2_to_p1) / (p1_to_p2 > p2_to_p1 ? p1_to_p2 : p2_to_p1);

        if (reciprocity > 0.8 && total > 10) {
          relationships.add(_Relationship(p1, p2, appLocalizations.key_relationships_strong_pair, reciprocity));
        } else if (reciprocity < 0.2 && total > 10) {
          relationships.add(_Relationship(p1, p2, appLocalizations.key_relationships_monologue, reciprocity));
        }
      }
    }

    return relationships;
  }

  Widget _buildRelationshipCard(_Relationship relationship, AppLocalizations appLocalizations) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                authorAvatar(relationship.p1),
                const Icon(Icons.sync_alt),
                authorAvatar(relationship.p2),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                relationship.type,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                appLocalizations.key_relationships_reciprocity(relationship.reciprocity.toStringAsFixed(2)),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Relationship {
  final String p1;
  final String p2;
  final String type;
  final double reciprocity;

  _Relationship(this.p1, this.p2, this.type, this.reciprocity);
}
