import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Logger global para guardar mensajes de la app
class Log {
  static final List<String> _messages = [];
  static final ValueNotifier<List<String>> notifier =
      ValueNotifier<List<String>>([]);

  /// Agrega un mensaje al log
  static void add(String message) {
    final timestamp = DateTime.now().toIso8601String().replaceFirst('T', ' ');
    final entry = "[$timestamp] $message";
    _messages.add(entry);
    notifier.value = List.from(_messages);
    debugPrint(entry); // también lo imprime en consola
  }

  /// Limpia los logs
  static void clear() {
    _messages.clear();
    notifier.value = [];
  }

  /// Devuelve todos los logs actuales
  static List<String> get messages => List.unmodifiable(_messages);
}

/// Widget para mostrar el log en un dialog
class LogViewerDialog extends StatelessWidget {
  const LogViewerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Application Log"),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ValueListenableBuilder<List<String>>(
          valueListenable: Log.notifier,
          builder: (context, messages, _) {
            if (messages.isEmpty) {
              return const Center(child: Text("No logs yet"));
            }
            return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Text(
                  messages[index],
                  style: const TextStyle(fontSize: 12),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            final logs = Log.messages.join('\n');
            Clipboard.setData(ClipboardData(text: logs));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logs copied to clipboard')),
            );
          },
          child: const Text("Copy"),
        ),
        TextButton(onPressed: () => Log.clear(), child: const Text("Clear")),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
