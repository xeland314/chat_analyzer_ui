import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import '../src/analysis/interaction_analyzer.dart';
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
        InteractionAnalysisView(analysis: widget.analysis),
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

class InteractionAnalysisView extends StatefulWidget {
  final ChatAnalysis analysis;
  const InteractionAnalysisView({super.key, required this.analysis});

  @override
  State<InteractionAnalysisView> createState() =>
      _InteractionAnalysisViewState();
}

class _InteractionAnalysisViewState extends State<InteractionAnalysisView> {
  late double _currentThreshold;
  late double _naturalThreshold;

  @override
  void initState() {
    super.initState();
    _naturalThreshold = widget.analysis.interactionAnalyzer
        .estimateNaturalThreshold();
    _currentThreshold = _naturalThreshold;
  }

  @override
  Widget build(BuildContext context) {
    final conversations = widget.analysis.interactionAnalyzer
        .segmentConversations(thresholdInMinutes: _currentThreshold);
    final starters = widget.analysis.interactionAnalyzer
        .calculateConversationStarters(conversations);
    final enders = widget.analysis.interactionAnalyzer
        .calculateConversationEnders(conversations);
    final metrics = widget.analysis.interactionAnalyzer
        .calculateInteractionMetrics(thresholdInMinutes: _currentThreshold);
    final responseTimes = metrics.averageResponseTime;
    final replies = metrics.whoRepliesToWhom;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interaction Analysis',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(),
            _buildThresholdSlider(),
            const SizedBox(height: 24),
            _buildStartersEndersChart(starters, enders),
            const SizedBox(height: 24),
            _buildResponseTimeChart(responseTimes),
            const SizedBox(height: 24),
            _buildReplyMatrix(replies),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conversation Threshold (minutes)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Detected natural threshold: ${_naturalThreshold.toStringAsFixed(1)} min. Use the slider to adjust.',
        ),
        Slider(
          value: _currentThreshold,
          min: 1,
          max: max(360, _naturalThreshold * 2), // 6 hours or 2x natural
          divisions: 359,
          label: _currentThreshold.round().toString(),
          onChanged: (value) {
            setState(() {
              _currentThreshold = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildStartersEndersChart(
    Map<String, int> starters,
    Map<String, int> enders,
  ) {
    final participants = (starters.keys.toSet()..addAll(enders.keys)).toList();
    if (participants.isEmpty) return const SizedBox.shrink();

    final barGroups = participants.asMap().entries.map((entry) {
      final index = entry.key;
      final name = entry.value;
      final starterCount = starters[name]?.toDouble() ?? 0.0;
      final enderCount = enders[name]?.toDouble() ?? 0.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: starterCount, color: Colors.blue, width: 12),
          BarChartRodData(toY: enderCount, color: Colors.amber, width: 12),
        ],
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conversation Starters & Enders',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: barGroups,
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < participants.length) {
                        return Text(
                          participants[index].substring(
                            0,
                            min(participants[index].length, 3),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend(Colors.blue, 'Started'),
            const SizedBox(width: 16),
            _buildLegend(Colors.amber, 'Ended'),
          ],
        ),
      ],
    );
  }

  Widget _buildResponseTimeChart(Map<String, Duration> responseTimes) {
    final entries = responseTimes.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (entries.isEmpty) return const SizedBox.shrink();

    final barGroups = entries.asMap().entries.map((entry) {
      final index = entry.key;
      final durationInMinutes = entry.value.value.inSeconds / 60.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: durationInMinutes,
            color: Colors.teal,
            width: 14,
          ),
        ],
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Average Response Time (minutes)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: barGroups,
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < entries.length) {
                        final name = entries[index].key;
                        return Text(name.substring(0, min(name.length, 3)));
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReplyMatrix(Map<String, Map<String, int>> replies) {
    final participants = replies.keys.toList()..sort();
    if (participants.isEmpty) return const SizedBox.shrink();

    final scrollController = ScrollController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who Replies to Whom',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),

        // 🔹 Scrollbar + SingleChildScrollView
        Scrollbar(
          controller: scrollController,
          thumbVisibility: true, // Siempre visible en desktop
          child: SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                const DataColumn(label: Text('Replier \\ To')),
                ...participants.map((p) => DataColumn(label: Text(p))),
              ],
              rows: participants.map((replier) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        replier,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...participants.map((repliee) {
                      final count = replies[replier]?[repliee] ?? 0;
                      return DataCell(Text(count.toString()));
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
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

class TemporalAnalysisView extends StatefulWidget {
  final ChatParticipant participant;

  const TemporalAnalysisView({super.key, required this.participant});

  @override
  State<TemporalAnalysisView> createState() => _TemporalAnalysisViewState();
}

class _TemporalAnalysisViewState extends State<TemporalAnalysisView> {
  late int _selectedYear;
  late List<int> _availableYears;

  @override
  void initState() {
    super.initState();
    final years = <int>{};
    years.addAll(widget.participant.messageCountPerDay.keys.map((d) => d.year));
    years.addAll(
      widget.participant.sentimentScorePerDay.keys.map((d) => d.year),
    );

    _availableYears = years.toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending

    _selectedYear = _availableYears.isNotEmpty
        ? _availableYears.first
        : DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    if (_availableYears.isEmpty &&
        widget.participant.messageCountByHour.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Temporal Analysis',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (_availableYears.length > 1) _buildYearSelector(),
          ],
        ),
        const Divider(),
        if (_availableYears.isNotEmpty)
          Column(
            children: [
              const SizedBox(height: 16),
              _buildActivityHeatmap(context, _selectedYear),
              const SizedBox(height: 24),
              _buildSentimentHeatmap(context, _selectedYear),
              const SizedBox(height: 24),
            ],
          ),
        _buildHourlyActivityChart(context), // This chart is year-agnostic
      ],
    );
  }

  Widget _buildYearSelector() {
    return DropdownButton<int>(
      value: _selectedYear,
      items: _availableYears.map((year) {
        return DropdownMenuItem<int>(value: year, child: Text(year.toString()));
      }).toList(),
      onChanged: (newYear) {
        if (newYear != null) {
          setState(() {
            _selectedYear = newYear;
          });
        }
      },
    );
  }

  Widget _buildActivityHeatmap(BuildContext context, int year) {
    final messageCount = widget.participant.messageCountPerDay;
    final yearlyData = Map.fromEntries(
      messageCount.entries.where((entry) => entry.key.year == year),
    );

    final scrollController = ScrollController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Message Activity ($year)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (yearlyData.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No message activity for this year.'),
          )
        else
          SizedBox(
            height: 250, // Altura fija para contener el heatmap + barra
            child: Scrollbar(
              controller: scrollController,
              thumbVisibility: true, // Siempre visible en desktop
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                child: HeatMap(
                  datasets: yearlyData,
                  startDate: DateTime(year, 1, 1),
                  endDate: DateTime(year, 12, 31),
                  colorMode: ColorMode.opacity,
                  showText: false,
                  colorsets: const {1: Colors.indigo},
                  onClick: (date) {
                    final count = yearlyData[date] ?? 0;
                    final snackBar = SnackBar(
                      content: Text('$count messages on this day'),
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
      ],
    );
  }

  Widget _buildHourlyActivityChart(BuildContext context) {
    final data = widget.participant.messageCountByHour;
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

  Widget _buildSentimentHeatmap(BuildContext context, int year) {
    final sentimentPerDay = widget.participant.sentimentScorePerDay;
    final yearlyData = Map.fromEntries(
      sentimentPerDay.entries.where((entry) => entry.key.year == year),
    );

    if (yearlyData.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sentiment Trend ($year)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No sentiment data for this year.'),
          ),
        ],
      );
    }

    final sentimentCategoryPerDay = yearlyData.map((date, score) {
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

    final scrollController = ScrollController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sentiment Trend ($year)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),

        // 🔹 Scrollbar + SingleChildScrollView para scroll en escritorio
        SizedBox(
          height: 250, // ajusta a la altura del heatmap
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: HeatMap(
                datasets: sentimentCategoryPerDay,
                startDate: DateTime(year, 1, 1),
                endDate: DateTime(year, 12, 31),
                colorMode: ColorMode.color,
                showText: false,
                showColorTip:
                    true, // si quieres que mantenga la leyenda de color
                colorsets: const {
                  -1: Colors.red, // Negative
                  1: Colors.green, // Positive
                  9: Colors.grey, // Neutral
                },
                onClick: (date) {
                  final score = yearlyData[date] ?? 0.0;
                  final category = sentimentCategoryPerDay[date] ?? 0;
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
