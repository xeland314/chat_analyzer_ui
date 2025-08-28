import 'dart:io';
import 'dart:math';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'src/analysis/analysis_service.dart';
import 'src/models/chat_analysis.dart';
import 'src/models/chat_message.dart';
import 'src/models/chat_participant.dart';

// --- Helper Functions ---

Future<ChatAnalysis> _analyzeInIsolate(String content) async {
  final service = AnalysisService();
  return await service.getAnalysis(content);
}

String getInitials(String name) => name.trim().split(RegExp(' + ')).map((s) => s[0]).take(2).join().toUpperCase();

Color colorForName(String name) {
  final hash = name.hashCode;
  final r = (hash & 0xFF0000) >> 16;
  final g = (hash & 0x00FF00) >> 8;
  final b = hash & 0x0000FF;
  return Color.fromRGBO(r, g, b, 1);
}

// --- Main App ---

void main() {
  runApp(const ChatAnalyzerApp());
}

class ChatAnalyzerApp extends StatelessWidget {
  const ChatAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Analyzer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// --- Home Page ---

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ChatAnalysis? _analysis;
  bool _isLoading = false;
  bool _isDragging = false;

  Future<void> _processChatContent(String content) async {
    setState(() {
      _isLoading = true;
      _analysis = null;
    });

    try {
      final analysis = await compute(_analyzeInIsolate, content);
      setState(() {
        _analysis = analysis;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing content: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickAndAnalyzeFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      await _processChatContent(await file.readAsString());
    }
  }

  void _resetAnalysis() {
    setState(() {
      _analysis = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Analyzer')),
      body: DropTarget(
        onDragDone: (details) async {
          if (details.files.isNotEmpty) {
            final file = details.files.first;
            await _processChatContent(await file.readAsString());
          }
        },
        onDragEntered: (details) => setState(() => _isDragging = true),
        onDragExited: (details) => setState(() => _isDragging = false),
        child: Container(
          color: _isDragging ? Colors.deepPurple.withOpacity(0.1) : Colors.transparent,
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : _analysis == null
                    ? _buildInitialView()
                    : AnalysisResultView(analysis: _analysis!),
          ),
        ),
      ),
      floatingActionButton: _analysis != null
          ? FloatingActionButton(
              onPressed: _resetAnalysis,
              tooltip: 'Analyze another chat',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildInitialView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cloud_upload_outlined, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        const Text('Drag and drop a .txt file here', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 16),
        const Text('or'),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _pickAndAnalyzeFile,
          icon: const Icon(Icons.upload_file),
          label: const Text('Load Chat File (.txt)'),
        ),
      ],
    );
  }
}

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
            Text('Display Options', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatViewScreen(
                      analysis: widget.analysis,
                    ),
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
                    decoration: const InputDecoration(labelText: 'Word to ignore'),
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
              const Text('No words are being ignored.', style: TextStyle(color: Colors.grey)),
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
    final filteredWordEntries = participant.wordFrequency.entries
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
            Text(participant.name, style: Theme.of(context).textTheme.headlineSmall),
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
        Text('Sentiment Analysis', style: Theme.of(context).textTheme.titleLarge),
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
                  titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                PieChartSectionData(
                  color: Colors.red,
                  value: negative.toDouble(),
                  title: '${(negative / total * 100).toStringAsFixed(0)}%',
                  radius: 50,
                  titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                PieChartSectionData(
                  color: Colors.grey,
                  value: neutral.toDouble(),
                  title: '${(neutral / total * 100).toStringAsFixed(0)}%',
                  radius: 50,
                  titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
        )
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
              leading: Text(entry.key, style: const TextStyle(fontFamily: 'Noto Color Emoji')),
              trailing: Text(entry.value.toString()),
            ),
          ),
      ],
    );
  }
}

// --- Unified Chat View Screen ---

class ChatViewScreen extends StatefulWidget {
  final ChatAnalysis analysis;

  const ChatViewScreen({super.key, required this.analysis});

  @override
  State<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends State<ChatViewScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _availableDates;
  late List<ChatMessage> _messagesToShow;
  late String _firstParticipantName;

  @override
  void initState() {
    super.initState();
    final messagesByDate = _groupMessagesByDate(widget.analysis.allMessagesChronological);
    _availableDates = messagesByDate.keys.toList()..sort((a, b) => b.compareTo(a));
    _firstParticipantName = widget.analysis.participants.first.name;

    if (_availableDates.isNotEmpty) {
      _selectedDate = _availableDates.first;
      _messagesToShow = messagesByDate[_selectedDate] ?? [];
    } else {
      _messagesToShow = [];
    }
  }

  Map<DateTime, List<ChatMessage>> _groupMessagesByDate(List<ChatMessage> messages) {
    final groupedMessages = <DateTime, List<ChatMessage>>{};
    for (final message in messages) {
      final date = DateTime(message.dateTime.year, message.dateTime.month, message.dateTime.day);
      if (groupedMessages.containsKey(date)) {
        groupedMessages[date]!.add(message);
      } else {
        groupedMessages[date] = [message];
      }
    }
    return groupedMessages;
  }

  void _onDateChanged(DateTime? newDate) {
    if (newDate != null) {
      setState(() {
        _selectedDate = newDate;
        final messagesByDate = _groupMessagesByDate(widget.analysis.allMessagesChronological);
        _messagesToShow = messagesByDate[_selectedDate] ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _availableDates.isEmpty
            ? const Text('Full Chat')
            : DropdownButton<DateTime>(
                value: _selectedDate,
                items: _availableDates.map((date) {
                  return DropdownMenuItem(
                    value: date,
                    child: Text(DateFormat.yMMMd().format(date)),
                  );
                }).toList(),
                onChanged: _onDateChanged,
              ),
      ),
      body: _messagesToShow.isEmpty
          ? const Center(child: Text('No messages on this date.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messagesToShow.length,
              itemBuilder: (context, index) {
                final message = _messagesToShow[index];
                final isMe = message.author == _firstParticipantName;
                return ChatMessageWidget(message: message, isMe: isMe);
              },
            ),
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const ChatMessageWidget({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final authorColor = colorForName(message.author);
    final authorInitials = getInitials(message.author);

    final bubble = Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.content, style: const TextStyle(fontFamily: 'Noto Color Emoji')),
            const SizedBox(height: 8),
            Text(
              DateFormat.jm().format(message.dateTime),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: (message.sentimentScore + 5).clamp(0, 10) / 10,
              backgroundColor: colorForName(message.author).withOpacity(0.2),
              color: message.sentimentScore > 0 ? Colors.green : (message.sentimentScore < 0 ? Colors.red : Colors.grey),
            ),
          ],
        ),
      ),
    );

    final avatar = CircleAvatar(
      backgroundColor: authorColor,
      child: Text(authorInitials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) avatar,
          const SizedBox(width: 8),
          Flexible(child: bubble),
          const SizedBox(width: 8),
          if (isMe) avatar,
        ],
      ),
    );
  }
}
