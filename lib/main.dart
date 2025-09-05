import 'package:flutter/material.dart';
import 'ui/pages/home_page.dart';

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
        colorScheme: ColorScheme.fromSeed(
          // Sugerencia de paleta para complementar el gato pixelado naranja
          // Puedes probar otras paletas como `Colors.amber` o `Colors.deepOrange`
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
