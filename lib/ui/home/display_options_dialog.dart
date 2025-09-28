
import 'package:flutter/material.dart';

class DisplayOptionsDialog extends StatefulWidget {
  final double initialDisplayCount;
  final Set<String> initialIgnoredWords;
  final Function(double) onDisplayCountChanged;
  final Function(Set<String>) onIgnoredWordsChanged;

  const DisplayOptionsDialog({
    super.key,
    required this.initialDisplayCount,
    required this.initialIgnoredWords,
    required this.onDisplayCountChanged,
    required this.onIgnoredWordsChanged,
  });

  @override
  State<DisplayOptionsDialog> createState() => _DisplayOptionsDialogState();
}

class _DisplayOptionsDialogState extends State<DisplayOptionsDialog> {
  late double _displayCount;
  late Set<String> _ignoredWords;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _displayCount = widget.initialDisplayCount;
    _ignoredWords = Set.from(widget.initialIgnoredWords);
  }

  void _addIgnoredWord() {
    final word = _textController.text.trim().toLowerCase();
    if (word.isNotEmpty) {
      setState(() {
        _ignoredWords.add(word);
      });
      _textController.clear();
    }
  }

  void _removeIgnoredWord(String word) {
    setState(() {
      _ignoredWords.remove(word);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Display Options'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text('Number of words to display'),
            Slider(
              value: _displayCount,
              min: 1,
              max: 20,
              divisions: 19,
              label: _displayCount.round().toString(),
              onChanged: (value) {
                setState(() {
                  _displayCount = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text('Ignored Words'),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Add a word to ignore',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addIgnoredWord,
                ),
              ),
              onSubmitted: (_) => _addIgnoredWord(),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: _ignoredWords
                  .map((word) => Chip(
                        label: Text(word),
                        onDeleted: () => _removeIgnoredWord(word),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onDisplayCountChanged(_displayCount);
            widget.onIgnoredWordsChanged(_ignoredWords);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
