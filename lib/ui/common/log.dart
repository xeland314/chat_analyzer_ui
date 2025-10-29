import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';

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
    final appLocalizations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(appLocalizations.log_title),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ValueListenableBuilder<List<String>>(
          valueListenable: Log.notifier,
          builder: (context, messages, _) {
            if (messages.isEmpty) {
              return Center(child: Text(appLocalizations.log_empty));
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
              SnackBar(content: Text(appLocalizations.reply_matrix_table_copied_snackbar)),
            );
          },
          child: Text(appLocalizations.reply_matrix_table_copy_button),
        ),
        TextButton(onPressed: () => Log.clear(), child: Text(appLocalizations.home_action_reset)),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.credits_modal_close_button),
        ),
      ],
    );
  }
}
