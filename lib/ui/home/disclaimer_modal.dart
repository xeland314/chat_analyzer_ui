import 'package:flutter/material.dart';

class DisclaimerModal extends StatelessWidget {
  const DisclaimerModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Esta app analiza solo chats que exportas manualmente de WhatsApp.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Aviso de Privacidad'),
                    content: const SingleChildScrollView(
                      child: Text(
                        'Esta aplicación procesa únicamente chats que tú '
                        'exportas manualmente desde WhatsApp. No accede a tu '
                        'cuenta ni recopila información automáticamente. '
                        'Todos los datos se analizan localmente en tu dispositivo '
                        'y se anonimiza la información sensible para proteger '
                        'la privacidad de terceros.',
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cerrar'),
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
              'Toca aquí para ver el aviso completo',
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
