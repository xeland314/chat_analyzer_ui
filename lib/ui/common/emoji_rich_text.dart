import 'package:chat_analyzer_ui/src/analysis/emoji_regex.dart';
import 'package:flutter/material.dart';


/// Construye un RichText mezclando texto normal y emojis con fuente especial.
Widget emojiRichText(
  String text, {
  TextStyle? baseStyle,
  String emojiFontFamily = 'Noto Color Emoji',
  TextOverflow overflow = TextOverflow.visible,
}) {
  final spans = <InlineSpan>[];
  String remaining = text;

  // Extraemos emojis con emoji_extension
  final emojis = EmojiRegex.extract(text);

  for (final emoji in emojis) {
    final index = remaining.indexOf(emoji);
    if (index != -1) {
      // Parte de texto antes del emoji
      if (index > 0) {
        spans.add(
          TextSpan(text: remaining.substring(0, index), style: baseStyle),
        );
      }

      // El emoji con fuente específica
      spans.add(
        TextSpan(
          text: emoji,
          style: (baseStyle ?? const TextStyle()).copyWith(
            fontFamily: emojiFontFamily,
          ),
        ),
      );

      // Recortamos el texto ya procesado
      remaining = remaining.substring(index + emoji.length);
    }
  }

  // Lo que quede después del último emoji
  if (remaining.isNotEmpty) {
    spans.add(TextSpan(text: remaining, style: baseStyle));
  }

  return Text.rich(TextSpan(children: spans), overflow: overflow);
}
