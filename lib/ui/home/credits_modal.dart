import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';

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
    final appLocalizations = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () => _launchUrl("https://www.buymeacoffee.com/xeland314"),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Image.asset(
          "assets/buy-me-a-cookie.png",
          height: 48,
          semanticLabel:
              appLocalizations.credits_modal_buy_me_a_cookie_semantic_label,
        ),
      ),
    );
  }
}

class BuyMeACoffeeButton extends StatelessWidget {
  const BuyMeACoffeeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () => _launchUrl("https://ko-fi.com/C0C41DCI4T"),
      child: Image.asset(
        "assets/buy-me-a-coffee.png",
        height: 48,
        semanticLabel: appLocalizations.credits_modal_buy_me_a_coffee_semantic_label,
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
    final appLocalizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(appLocalizations.credits_modal_title),
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
              Text(
                appLocalizations.credits_modal_intro,
                textAlign: TextAlign.center,
              ),
              Text(
                appLocalizations.credits_modal_my_name,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Reemplazando el link de texto por un Row con un ícono
              InkWell(
                onTap: () => _launchUrl("https://github.com/xeland314"),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.code), // Ícono de GitHub
                    SizedBox(width: 8),
                    Text(
                      appLocalizations.credits_modal_github_profile,
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
                  children: [
                    Icon(Icons.link), // Ícono de Portafolio/Link
                    SizedBox(width: 8),
                    Text(
                      appLocalizations.credits_modal_portfolio,
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                appLocalizations.credits_modal_donations,
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
          child: Text(appLocalizations.credits_modal_close_button),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
