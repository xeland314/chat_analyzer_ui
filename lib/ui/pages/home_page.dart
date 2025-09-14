import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import '../../src/analysis/analysis_service.dart';
import '../../src/models/chat_analysis.dart';
import '../home/analysis_view.dart';
import '../common/log.dart';

// --- Helper ---
Future<ChatAnalysis> _analyzeInIsolate(String content) async {
  final service = AnalysisService();
  return await service.getAnalysis(content);
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
      final analysis = await compute(_analyzeInIsolate, content);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Analyzer'),
        backgroundColor: Colors.teal,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const LogViewerDialog(),
              );
            },
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
            ),
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
}
