import 'package:flutter/material.dart';
import '../../common/emoji_rich_text.dart';
import '../../chat/chat_avatar.dart';

class TopTransitionsView extends StatefulWidget {
  final Map<String, Map<String, double>> transitionMatrix;

  const TopTransitionsView({super.key, required this.transitionMatrix});

  @override
  State<TopTransitionsView> createState() => _TopTransitionsViewState();
}

class _TopTransitionsViewState extends State<TopTransitionsView> {
  int _topCount = 3;
  int _maxTransitions = 1;
  List<MapEntry<String, MapEntry<String, double>>> _topTransitions = [];

  @override
  void initState() {
    super.initState();
    _calculateMaxTransitions();
    _updateTopTransitions();
  }

  void _calculateMaxTransitions() {
    int count = 0;
    widget.transitionMatrix.forEach((_, toMap) {
      count += toMap.length;
    });
    setState(() {
      _maxTransitions = count > 0 ? count : 1;
      if (_topCount > _maxTransitions) {
        _topCount = _maxTransitions;
      }
    });
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
      _topTransitions = transitions.take(_topCount).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        emojiRichText(
          '¿Quién responde a quién?',
          baseStyle: Theme.of(context).textTheme.titleLarge,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),

        Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: // Slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top $_topCount de $_maxTransitions transiciones',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Slider(
                  value: _topCount.toDouble(),
                  min: 1,
                  max: _maxTransitions.toDouble(),
                  divisions: _maxTransitions - 1,
                  label: '$_topCount',
                  onChanged: (double value) {
                    setState(() {
                      _topCount = value.round();
                      _updateTopTransitions();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        /// Aquí la Card envuelve la lista de transiciones
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: _topTransitions.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final from = entry.value.key;
                final to = entry.value.value.key;
                final value = entry.value.value.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Text('$index. '),
                      authorAvatar(from),
                      const Text(' → '),
                      authorAvatar(to),
                      Text(' (${(value * 100).toStringAsFixed(2)}%)'),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
