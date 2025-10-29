import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class InfoWidgetWrapper extends StatelessWidget {
  final Widget child;
  final String title;
  final String infoContent;

  const InfoWidgetWrapper({
    super.key,
    required this.child,
    required this.title,
    required this.infoContent,
  });

  void _showInfoDialog(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ℹ️ $title'),
          content: SingleChildScrollView(child: Text(infoContent)),
          actions: <Widget>[
            TextButton(
              child: Text(appLocalizations.credits_modal_close_button),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        child,
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(Icons.info_outline, size: 18),
            label: Text(
              appLocalizations.info_wrapper_info_button,
              style: const TextStyle(fontSize: 12),
            ),
            onPressed: () => _showInfoDialog(context),
          ),
        ),
      ],
    );
  }
}
