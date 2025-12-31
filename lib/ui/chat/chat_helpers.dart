import 'dart:math';
import 'package:flutter/material.dart';
import '../../src/models/chat_message.dart';

/// Devuelve una representación corta del nombre, número o emojis para mostrar en el chat.
///
/// Reglas principales:
/// - Si [name] contiene emojis, se priorizan hasta 2 emojis (en el orden en que aparecen).
/// - Si hay menos de 2 emojis, se complementa con iniciales de palabras (letras en mayúscula) o
///   con dígitos, hasta completar 2 "unidades" visibles.
/// - Si [name] es completamente numérico, se devuelven los últimos 3 dígitos.
/// - Las letras se devuelven en mayúscula; los emojis se devuelven tal cual.
/// - Si la entrada está vacía, retorna cadena vacía.
///
/// Ejemplos:
/// ```dart
/// getInitials("John Doe");   // "JD"
/// getInitials("Alice");      // "A"
/// getInitials("5551234567"); // "567" (numérico completo -> últimos 3 dígitos)
/// getInitials("🙂");           // "🙂"
/// getInitials("🙂 John");     // "🙂J" (emoji + inicial)
/// getInitials("🙂🙂 John");   // "🙂🙂" (dos emojis)
/// getInitials("1234🙂");      // "🙂4" (emoji primero, luego dígitos si faltan)
/// ```
String getInitials(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '';

  // Detectores básicos
  final hasLetters = RegExp(r'[A-Za-z]').hasMatch(trimmed);
  final digits = trimmed.replaceAll(RegExp(r'\D'), '');

  // Regex para capturar emojis comunes (varias áreas Unicode). Usamos unicode: true.
  final emojiRegex = RegExp(
    r'[\u{1F600}-\u{1F64F}'
    r'\u{1F300}-\u{1F5FF}'
    r'\u{1F680}-\u{1F6FF}'
    r'\u{2600}-\u{26FF}'
    r'\u{2700}-\u{27BF}'
    r'\u{1F900}-\u{1F9FF}'
    r'\u{1FA70}-\u{1FAFF}]',
    unicode: true,
  );

  // Si no hay letras y tampoco emojis, mantenemos comportamiento numérico original
  final emojiMatches = emojiRegex.allMatches(trimmed).map((m) => m.group(0)!).toList();
  if (!hasLetters && emojiMatches.isEmpty) {
    if (digits.length >= 3) return digits.substring(digits.length - 3);
    return digits;
  }

  // Construimos hasta 2 "caracteres" para mostrar, priorizando emojis,
  // luego iniciales de palabras (letra o número) y por último dígitos si faltan.
  final initials = <String>[];

  // 1) Añadir hasta 2 emojis en el orden en que aparecen
  for (final e in emojiMatches) {
    if (initials.length >= 2) break;
    initials.add(e);
  }

  // 2) Añadir iniciales de palabras (siempre en mayúscula para letras)
  if (initials.length < 2) {
    final words = trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    for (final w in words) {
      if (initials.length >= 2) break;
      // Si la palabra comienza con un emoji, tomamos ese emoji (si no lo hemos añadido ya)
      final emo = emojiRegex.matchAsPrefix(w)?.group(0);
      if (emo != null) {
        if (!initials.contains(emo)) initials.add(emo);
        continue;
      }

      // Si es una palabra alfabética, tomar primera letra en mayúscula
      final first = w[0];
      if (RegExp(r'[A-Za-z]').hasMatch(first)) {
        initials.add(first.toUpperCase());
      } else if (RegExp(r'\d').hasMatch(first)) {
        // Si la palabra contiene un emoji pero no al inicio (ej: "1234🙂"),
        // preferimos tomar el último dígito antes del emoji para que el
        // resultado sea más representativo (ej: "🙂4").
        final emojiInWord = emojiRegex.firstMatch(w);
        if (emojiInWord != null && emojiInWord.start > 0) {
          // Tomar el último dígito antes del primer emoji
          final beforeEmoji = w.substring(0, emojiInWord.start);
          final lastDigitMatch = RegExp(r'\d').allMatches(beforeEmoji).map((m) => m.group(0)).whereType<String>().toList();
          if (lastDigitMatch.isNotEmpty) {
            initials.add(lastDigitMatch.last);
          } else {
            initials.add(first);
          }
        } else {
          initials.add(first);
        }
      } else {
        // fallback: añadir el primer código unit si no es letra/dígito
        initials.add(first);
      }
    }
  }

  // 3) Si aún faltan, rellenar con los últimos dígitos (en orden correcto)
  if (initials.length < 2 && digits.isNotEmpty) {
    final need = 2 - initials.length;
    final start = digits.length - need;
    final fill = digits.substring(start < 0 ? 0 : start);
    for (final ch in fill.split('')) {
      if (initials.length >= 2) break;
      initials.add(ch);
    }
  }

  return initials.join();
}

/// Genera un color único a partir de un [name].
///
/// La función calcula un hash del nombre y lo convierte a un color RGB.
/// Si el color resultante es demasiado claro o amarillo, se ajusta el
/// tono y la luminosidad para mejorar la legibilidad.
///
/// Ejemplo:
/// ```dart
/// final color = colorForName("Alice");
/// ```
Color colorForName(String name) {
  final hash = name.hashCode;

  // Color base desde el hash
  int r = (hash & 0xFF0000) >> 16;
  int g = (hash & 0x00FF00) >> 8;
  int b = hash & 0x0000FF;

  Color color = Color.fromRGBO(r, g, b, 1);

  // Función para calcular luminancia relativa (0=negro, 1=blanco)
  double luminance(Color c) {
    return (0.299 * c.r + 0.587 * c.g + 0.114 * c.b);
  }

  // Detectar si es "demasiado claro"
  bool isTooLight(Color c) => luminance(c) > 0.75;

  // Detectar si es cercano a amarillo (alto R y G, bajo B)
  bool isYellowish(Color c) =>
      ((c.r * 255.0).round() & 0xff) > 200 &&
      ((c.g * 255.0).round() & 0xff) > 200 &&
      ((c.b * 255.0).round() & 0xff) < 150;

  // Ajustar color si es muy claro o amarillento
  if (isTooLight(color) || isYellowish(color)) {
    // Convertimos a HSL para manipular tono y luminosidad
    final hsl = HSLColor.fromColor(color);

    // Si es claro, bajamos luminosidad; si es amarillo, giramos tono hacia otra gama
    double newHue = hsl.hue;
    if (isYellowish(color)) {
      newHue = (hsl.hue + 180) % 360; // rotar a color opuesto
    }

    color = hsl
        .withHue(newHue)
        .withLightness(min(hsl.lightness, 0.5))
        .withSaturation(max(hsl.saturation, 0.5))
        .toColor();
  }

  return color;
}

/// Devuelve un color que representa el sentimiento de un mensaje.
///
/// - Si [score] es mayor que 0, devuelve [Colors.green] (positivo).
/// - Si [score] es menor que 0, devuelve [Colors.red] (negativo).
/// - Si [score] es 0, devuelve [Colors.grey] (neutral).
///
/// Ejemplos:
/// ```dart
/// sentimentColor(3.5); // Colors.green
/// sentimentColor(-2.0); // Colors.red
/// sentimentColor(0); // Colors.grey
/// ```
Color sentimentColor(double score) {
  if (score > 0) return Colors.green;
  if (score < 0) return Colors.red;
  return Colors.grey;
}

/// Agrupa una lista de mensajes por fecha (ignorando hora/min/seg).
///
/// Retorna un mapa donde la clave es la fecha (sin tiempo)
/// y el valor es la lista de mensajes correspondientes a ese día.
Map<DateTime, List<ChatMessage>> groupMessagesByDate(
  List<ChatMessage> messages,
) {
  final groupedMessages = <DateTime, List<ChatMessage>>{};
  for (final message in messages) {
    final date = DateTime(
      message.dateTime.year,
      message.dateTime.month,
      message.dateTime.day,
    );
    groupedMessages.putIfAbsent(date, () => []).add(message);
  }
  return groupedMessages;
}
