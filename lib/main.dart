import 'package:flutter/material.dart';
import 'ui/home.dart';

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
