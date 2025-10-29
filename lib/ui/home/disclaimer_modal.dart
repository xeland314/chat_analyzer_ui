import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class DisclaimerModal extends StatelessWidget {
  const DisclaimerModal({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            appLocalizations.disclaimer_modal_text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(appLocalizations.disclaimer_modal_privacy_notice_title),
                    content: SingleChildScrollView(
                      child: Text(
                        appLocalizations.disclaimer_modal_privacy_notice_content,
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(appLocalizations.disclaimer_modal_privacy_notice_close_button),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Text(
              appLocalizations.disclaimer_modal_privacy_notice_touch_to_view,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
