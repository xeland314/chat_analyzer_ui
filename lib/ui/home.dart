import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../src/analysis/analysis_service.dart';
import '../src/models/chat_analysis.dart';
import 'results.dart';

// --- Helper Functions ---

Future<ChatAnalysis> _analyzeInIsolate(String content) async {
  final service = AnalysisService();
  return await service.getAnalysis(content);
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error processing content: $e')));
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
          color: _isDragging
              ? Colors.deepPurple.withOpacity(0.1)
              : Colors.transparent,
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
        const Text(
          'Drag and drop a .txt file here',
          style: TextStyle(fontSize: 18),
        ),
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
