import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../src/analysis/analysis_service.dart';
import '../../src/models/chat_analysis.dart';
import '../home/analysis_view.dart';

// --- Helper Functions ---

Future<ChatAnalysis> _analyzeInIsolate(String content) async {
  final service = AnalysisService();
  return await service.getAnalysis(content);
}

// --- HomePage (El componente Stateful para la lógica y el estado) ---

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
      if (!mounted) return;
      setState(() {
        _analysis = analysis;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error processing content: $e')));
    }

    if (!mounted) return;
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
      appBar: AppBar(
        title: const Text('Chat Analyzer'),
        backgroundColor: Colors.indigo,
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
              ? Colors.indigo.withOpacity(0.5)
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
