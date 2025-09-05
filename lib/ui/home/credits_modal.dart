import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Lanza una URL en el navegador.
Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    throw Exception('No se pudo lanzar la URL: $uri');
  }
}

class BuyMeACookieButton extends StatelessWidget {
  const BuyMeACookieButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _launchUrl("https://www.buymeacoffee.com/xeland314"),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Image.asset(
          "assets/buy-me-a-cookie.png",
          height: 48,
          semanticLabel:
              'Buy me a cookie at https://www.buymeacoffee.com/xeland314',
        ),
      ),
    );
  }
}

class BuyMeACoffeeButton extends StatelessWidget {
  const BuyMeACoffeeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _launchUrl("https://ko-fi.com/C0C41DCI4T"),
      child: Image.asset(
        "assets/buy-me-a-coffee.png",
        height: 48,
        semanticLabel: 'Buy Me a Coffee at ko-fi.com/C0C41DCI4T',
      ),
    );
  }
}

class PaymentButtons extends StatelessWidget {
  const PaymentButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      alignment: WrapAlignment.center,
      children: const [BuyMeACookieButton(), BuyMeACoffeeButton()],
    );
  }
}

class CreditsModal extends StatelessWidget {
  const CreditsModal({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final horizontalPadding = isSmallScreen ? 0.0 : 24.0;

    return AlertDialog(
      title: const Text('Créditos'),
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Desarrollado por xeland314',
                textAlign: TextAlign.center,
              ),
              const Text(
                '(Christopher Villamarín), 2025.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Reemplazando el link de texto por un Row con un ícono
              InkWell(
                onTap: () => _launchUrl("https://github.com/xeland314"),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.code), // Ícono de GitHub
                    SizedBox(width: 8),
                    Text(
                      'Perfil de GitHub',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Reemplazando el link de texto por un Row con un ícono
              InkWell(
                onTap: () => _launchUrl("https://xeland314.github.io/"),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.link), // Ícono de Portafolio/Link
                    SizedBox(width: 8),
                    Text(
                      'Portafolio',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Donaciones:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const PaymentButtons(),
            ],
          ),
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
  }
}
