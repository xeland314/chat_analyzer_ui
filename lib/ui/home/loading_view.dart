import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../common/emoji_rich_text.dart';
import '../../l10n/app_localizations.dart';

class LoadingView extends StatefulWidget {
  const LoadingView({super.key});

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
  // Lista de frases divertidas
  late List<String> _phrases;

  late String _currentPhrase;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final appLocalizations = AppLocalizations.of(context)!;

    // Inicializa la lista con todas las frases traducidas
    _phrases = [
      appLocalizations.cat_phrase_1,
      appLocalizations.cat_phrase_2,
      appLocalizations.cat_phrase_3,
      appLocalizations.cat_phrase_4,
      appLocalizations.cat_phrase_5,
      appLocalizations.cat_phrase_6,
      appLocalizations.cat_phrase_7,
      appLocalizations.cat_phrase_8,
      appLocalizations.cat_phrase_9,
      appLocalizations.cat_phrase_10,
    ];

    if (!mounted) {
      _currentPhrase = _phrases[Random().nextInt(_phrases.length)];
    }

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
            semanticLabel: AppLocalizations.of(context)!.loading_view_pixel_cat_semantic_label,
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
