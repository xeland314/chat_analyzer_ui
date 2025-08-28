import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
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
      child: ExpansionTile(
        title: Text(
          participant.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        subtitle: Text(
          '${participant.messageCount} messages, ${participant.multimediaCount} multimedia files',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSentimentSection(context),
                const SizedBox(height: 16),
                FrequencyListView(title: 'Most Common Words', data: topWords),
                const SizedBox(height: 16),
                FrequencyListView(
                  title: 'Most Common Emojis',
                  data: participant.getMostCommonEmojis(displayCount),
                ),
                TemporalAnalysisView(participant: participant),
              ],
            ),
          ),
        ],
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

class TemporalAnalysisView extends StatelessWidget {
  final ChatParticipant participant;

  const TemporalAnalysisView({super.key, required this.participant});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Temporal Analysis',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Divider(),
        const SizedBox(height: 16),
        _buildActivityHeatmap(context),
        const SizedBox(height: 24),
        _buildHourlyActivityChart(context),
        const SizedBox(height: 24),
        _buildSentimentHeatmap(context),
      ],
    );
  }

  Widget _buildActivityHeatmap(BuildContext context) {
    final messageCount = participant.messageCountPerDay;

    final scrollController = ScrollController();

    // Find the min and max dates to set the calendar range
    final dates = messageCount.keys.toList()..sort();
    final firstDate = dates.first;
    final lastDate = dates.last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Message Activity', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),

        // 🌟 Envolvemos en Scrollbar + SingleChildScrollView horizontal
        SizedBox(
          height: 250, // ajusta según tamaño de tu heatmap
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true, // para que se vea siempre
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: HeatMap(
                datasets: messageCount.map((k, v) => MapEntry(k, v)),
                colorMode: ColorMode.opacity,
                showText: false,
                showColorTip: true,
                scrollable: true,
                startDate: firstDate,
                endDate: lastDate,
                colorsets: const {1: Colors.indigo},
                onClick: (date) {
                  final count = messageCount[date] ?? 0;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$count messages on this day')),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyActivityChart(BuildContext context) {
    final data = participant.messageCountByHour;
    if (data.isEmpty) return const SizedBox.shrink();

    final entries = List.generate(24, (hour) {
      return BarChartGroupData(
        x: hour,
        barRods: [
          BarChartRodData(
            toY: data[hour]?.toDouble() ?? 0.0,
            color: Colors.blue,
            width: 10,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Most Active Hours',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: BarChart(
            BarChartData(
              barGroups: entries,
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final hour = value.toInt();
                      if (hour % 3 == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('${hour}h'),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 28,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.round()} messages',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSentimentHeatmap(BuildContext context) {
    final sentimentPerDay = participant.sentimentScorePerDay;
    if (sentimentPerDay.isEmpty) return const SizedBox.shrink();

    final sentimentCategoryPerDay = sentimentPerDay.map((date, score) {
      int category;
      if (score > 0.05) {
        category = 1; // Positive
      } else if (score < -0.05) {
        category = -1; // Negative
      } else {
        category = 9; // Neutral
      }
      return MapEntry(date, category);
    });

    final dates = sentimentPerDay.keys.toList()..sort();
    final firstDate = dates.first;
    final lastDate = dates.last;

    final scrollController = ScrollController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sentiment Trend', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),

        // ⬇ Envoltorio scrollable
        SizedBox(
          height: 250, // Ajusta según el tamaño del heatmap
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true, // Siempre visible en desktop
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: HeatMap(
                datasets: sentimentCategoryPerDay,
                startDate: firstDate,
                endDate: lastDate,
                colorMode: ColorMode.color,
                showText: false,
                showColorTip: true,
                colorsets: const {
                  -1: Colors.red, // Negative
                  1: Colors.green, // Positive
                  9: Colors.grey, // Neutral
                },
                onClick: (date) {
                  final score = sentimentPerDay[date] ?? 0.0;
                  final category = sentimentCategoryPerDay[date]!;
                  String sentimentText = category > 0
                      ? 'Positive'
                      : category < 0
                      ? 'Negative'
                      : 'Neutral';

                  final snackBar = SnackBar(
                    content: Text(
                      '$sentimentText sentiment (${score.toStringAsFixed(2)}) on this day',
                    ),
                    action: SnackBarAction(
                      label: 'Close',
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegend(Colors.green, 'Positive'),
            _buildLegend(Colors.red, 'Negative'),
            _buildLegend(Colors.grey.shade400, 'Neutral'),
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
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('No data found.'),
          )
        else
          ...data.map(
            (entry) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Text(
                entry.key,
                style: const TextStyle(
                  fontFamily: 'Noto Color Emoji',
                  fontSize: 18,
                ),
              ),
              title: Text(entry.key),
              trailing: Text(
                entry.value.toString(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
      ],
    );
  }
}
