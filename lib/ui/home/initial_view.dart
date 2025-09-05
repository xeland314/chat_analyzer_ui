import 'package:flutter/material.dart';
import 'credits_modal.dart';
import 'disclaimer_modal.dart';

class InitialView extends StatelessWidget {
  final VoidCallback onFilePick;

  const InitialView({super.key, required this.onFilePick});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_upload_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Arrastra y suelta un archivo .txt aquí',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          const Text('o'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onFilePick,
            icon: const Icon(Icons.upload_file),
            label: const Text('Cargar archivo de chat (.txt)'),
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
            child: const Text('Créditos'),
          ),
        ],
      ),
    );
  }
}
