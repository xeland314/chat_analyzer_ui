import 'package:flutter/material.dart';
import 'credits_modal.dart';
import 'disclaimer_modal.dart';
import '../../l10n/app_localizations.dart';

class InitialView extends StatelessWidget {
  final VoidCallback onFilePick;

  const InitialView({super.key, required this.onFilePick});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_upload_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            appLocalizations.initial_view_message_1,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Text(appLocalizations.initial_view_message_2),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onFilePick,
            icon: const Icon(Icons.upload_file),
            label: Text(appLocalizations.initial_view_message_3),
          ),
          const SizedBox(height: 32),
          const DisclaimerModal(),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const CreditsModal();
                },
              );
            },
            child: Text(appLocalizations.initial_view_credits_button),
          ),
        ],
      ),
    );
  }
}
