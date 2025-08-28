import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../src/models/chat_analysis.dart';
import '../src/models/chat_participant.dart';
import 'chat.dart';

// --- Results Screen Widgets ---

class AnalysisResultView extends StatefulWidget {
  final ChatAnalysis analysis;

  const AnalysisResultView({super.key, required this.analysis});

  @override
  State<AnalysisResultView> createState() => _AnalysisResultViewState();
}

class _AnalysisResultViewState extends State<AnalysisResultView> {
  double _displayCount = 5.0;
  final Set<String> _customIgnoredWords = {};
  final _textController = TextEditingController();

  void _addIgnoredWord() {
    final word = _textController.text.trim().toLowerCase();
    if (word.isNotEmpty) {
      setState(() {
        _customIgnoredWords.add(word);
      });
      _textController.clear();
    }
  }

  void _removeIgnoredWord(String word) {
    setState(() {
      _customIgnoredWords.remove(word);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildControlsCard(context),
        const SizedBox(height: 16),
        ...widget.analysis.participants.map(
          (p) => ParticipantStatsView(
            participant: p,
            displayCount: _displayCount.round(),
            ignoredWords: _customIgnoredWords,
          ),
        ),
      ],
    );
  }

  Widget _buildControlsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Display Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatViewScreen(analysis: widget.analysis),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('View Full Chat'),
            ),
            const SizedBox(height: 16),
            Text('Show Top: ${_displayCount.round()}'),
            Slider(
              value: _displayCount,
              min: 5,
              max: 30,
              divisions: 25,
              label: _displayCount.round().toString(),
              onChanged: (value) {
                setState(() {
                  _displayCount = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Text('Ignore Words', style: Theme.of(context).textTheme.titleLarge),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Word to ignore',
                    ),
                    onSubmitted: (_) => _addIgnoredWord(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addIgnoredWord,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_customIgnoredWords.isNotEmpty)
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _customIgnoredWords.map((word) {
                  return Chip(
                    label: Text(word),
                    onDeleted: () => _removeIgnoredWord(word),
                  );
                }).toList(),
              )
            else
              const Text(
                'No words are being ignored.',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

class ParticipantStatsView extends StatelessWidget {
  final ChatParticipant participant;
  final int displayCount;
  final Set<String> ignoredWords;

  const ParticipantStatsView({
    super.key,
    required this.participant,
    required this.displayCount,
    required this.ignoredWords,
  });

  @override
  Widget build(BuildContext context) {
    final filteredWordEntries =
        participant.wordFrequency.entries
            .where((entry) => !ignoredWords.contains(entry.key))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    final topWords = filteredWordEntries.take(displayCount).toList();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              participant.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text('${participant.messageCount} messages'),
            Text('${participant.multimediaCount} multimedia files'),
            const SizedBox(height: 16),
            _buildSentimentSection(context),
            const SizedBox(height: 16),
            FrequencyListView(title: 'Most Common Words', data: topWords),
            const SizedBox(height: 16),
            FrequencyListView(
              title: 'Most Common Emojis',
              data: participant.getMostCommonEmojis(displayCount),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentSection(BuildContext context) {
    final sentimentData = participant.sentimentAnalysis;
    final positive = sentimentData['Positive']!;
    final negative = sentimentData['Negative']!;
    final neutral = sentimentData['Neutral']!;
    final total = positive + negative + neutral;

    if (total == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sentiment Analysis',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: Colors.green,
                  value: positive.toDouble(),
                  title: '${(positive / total * 100).toStringAsFixed(0)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.red,
                  value: negative.toDouble(),
                  title: '${(negative / total * 100).toStringAsFixed(0)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.grey,
                  value: neutral.toDouble(),
                  title: '${(neutral / total * 100).toStringAsFixed(0)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegend(Colors.green, 'Positive: $positive'),
            _buildLegend(Colors.red, 'Negative: $negative'),
            _buildLegend(Colors.grey, 'Neutral: $neutral'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}

class FrequencyListView extends StatelessWidget {
  final String title;
  final List<MapEntry<String, int>> data;

  const FrequencyListView({super.key, required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (data.isEmpty)
          const Text('No data found.')
        else
          ...data.map(
            (entry) => ListTile(
              dense: true,
              leading: Text(
                entry.key,
                style: const TextStyle(fontFamily: 'Noto Color Emoji'),
              ),
              trailing: Text(entry.value.toString()),
            ),
          ),
      ],
    );
  }
}
