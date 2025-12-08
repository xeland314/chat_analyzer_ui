import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:uuid/uuid.dart';
import '../../src/analysis/analysis_service.dart';
import '../../src/models/chat_analysis.dart';
import '../chat/chat_view_screen.dart';
import '../home/analysis_view.dart';
import '../common/log.dart';
import '../home/display_options_dialog.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';

// --- Helper ---
Future<ChatAnalysis> _analyzeInIsolate(Map<String, String> args) async {
  final service = AnalysisService();
  final content = args['content']!;
  final id = args['id']!;
  return await service.getAnalysis(content, id: id);
}

class HomePage extends StatefulWidget {
  final String initialText;
  const HomePage({super.key, required this.initialText});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ChatAnalysis? _analysis;
  bool _isLoading = false;
  bool _isDragging = false;
  double _displayCount = 5.0;
  final Set<String> _customIgnoredWords = {};

  @override
  void initState() {
    super.initState();
    // Procesar el texto inicial si se recibió desde un intent de compartir
    if (widget.initialText.isNotEmpty) {
      _processChatContent(widget.initialText);
    }
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != oldWidget.initialText &&
        widget.initialText.isNotEmpty) {
      _processChatContent(widget.initialText);
    }
  }

  Future<void> _processChatContent(String content) async {
    setState(() {
      _isLoading = true;
      _analysis = null;
    });

    try {
      final id = const Uuid().v4();
      final analysis = await compute(_analyzeInIsolate, {'content': content, 'id': id});
      if (!mounted) return;
      setState(() => _analysis = analysis);
      Log.add("Analysis completed successfully");
    } catch (e) {
      if (!mounted) return;
      Log.add("Error processing content: $e");
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _pickAndAnalyzeFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      await _processChatContent(content);
    }
  }

  void _resetAnalysis() {
    setState(() => _analysis = null);
  }

  void _openDisplayOptions() {
    showDialog(
      context: context,
      builder: (context) => DisplayOptionsDialog(
        initialDisplayCount: _displayCount,
        initialIgnoredWords: _customIgnoredWords,
        onDisplayCountChanged: (value) {
          setState(() {
            _displayCount = value;
          });
        },
        onIgnoredWordsChanged: (words) {
          setState(() {
            _customIgnoredWords.clear();
            _customIgnoredWords.addAll(words);
          });
        },
      ),
    );
  }

  void _viewFullChat() {
    if (_analysis != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatViewScreen(analysis: _analysis!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.name),
        backgroundColor: Colors.teal,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        actions: [
          if (_analysis != null)
            IconButton(
              icon: const Icon(Icons.description),
              onPressed: _openAiGuide,
              tooltip: 'AI Guide',
              color: Colors.white,
            ),
          if (_analysis != null)
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: _viewFullChat,
              tooltip: appLocalizations.home_action_tooltip,
              color: Colors.white,
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openDisplayOptions,
            tooltip: appLocalizations.home_action_display,
            color: Colors.white,
          ),
          if (_analysis != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetAnalysis,
              tooltip: appLocalizations.home_action_reset,
              color: Colors.white,
            ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const LogViewerDialog(),
              );
            },
            tooltip: appLocalizations.home_action_logs,
            color: Colors.white,
          ),
        ],
      ),
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
          color: _isDragging
              ? Colors.amber.withOpacity(0.5)
              : Colors.transparent,
          child: Center(
            child: AnalysisView(
              isLoading: _isLoading,
              analysis: _analysis,
              onFilePick: _pickAndAnalyzeFile,
              displayCount: _displayCount,
              ignoredWords: _customIgnoredWords,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openAiGuide() async {
    try {
      final content = await rootBundle.loadString('docs/AI_USAGE_AND_PROMPTS.md');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('AI Guide'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(content),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Copy all content to clipboard
                Clipboard.setData(ClipboardData(text: content));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('AI guide copied to clipboard')),
                );
              },
              child: const Text('Copy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load AI guide: $e')),
      );
    }
  }
}
