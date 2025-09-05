import 'dart:math';
import 'package:flutter/material.dart';
import '../../src/models/chat_message.dart';

/// Devuelve una representación corta del nombre o número para mostrar en el chat.
///
/// - Si [name] contiene letras, devuelve las iniciales de hasta las dos primeras palabras.
/// - Si [name] es solo numérico (ej. un teléfono), devuelve los últimos 3 dígitos.
/// - Siempre devuelve una cadena en mayúsculas.
///
/// Ejemplos:
/// ```dart
/// getInitials("John Doe"); // "JD"
/// getInitials("Alice");    // "A"
/// getInitials("5551234567"); // "567"
/// ```
String getInitials(String name) {
  final trimmed = name.trim();

  // Si el nombre contiene alguna letra, usamos iniciales
  final hasLetters = RegExp(r'[A-Za-z]').hasMatch(trimmed);
  if (hasLetters) {
    return trimmed
        .split(RegExp(r'\s+'))
        .map((s) => s[0])
        .take(2)
        .join()
        .toUpperCase();
  }

  // Si es solo numérico, tomamos los últimos 3 caracteres
  final digits = trimmed.replaceAll(RegExp(r'\D'), '');
  if (digits.length >= 3) {
    return digits.substring(digits.length - 3);
  } else {
    // Si tiene menos de 3 dígitos, devolvemos todo
    return digits;
  }
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
