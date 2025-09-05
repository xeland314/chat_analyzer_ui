import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../common/emoji_rich_text.dart';

class LoadingView extends StatefulWidget {
  const LoadingView({super.key});

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
  // Lista de frases divertidas
  final List<String> _phrases = [
    'Analizando chats...',
    'Vi algo que no debí ver...',
    'Gatito trabajando, no molestar...',
    'Calculando los chismes... esto tomará un momento.',
    'Contando emojis... 😼',
    'Conspirando para dominar el mundo... o solo el chat.',
    'Limpiando las patitas... ya casi termino.',
  ];

  late String _currentPhrase;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Inicia con una frase aleatoria
    _currentPhrase = _phrases[Random().nextInt(_phrases.length)];
    // Inicia un temporizador para cambiar la frase cada 3 segundos
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      if (mounted) {
        setState(() {
          _currentPhrase = _phrases[Random().nextInt(_phrases.length)];
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela el temporizador cuando el widget se destruye
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/pixel-cat.png',
            height: 120,
            semanticLabel: 'Gato pixelado trabajando',
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: emojiRichText(
              _currentPhrase,
              baseStyle: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                color: Colors.blueGrey,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
