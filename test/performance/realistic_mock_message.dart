import 'dart:math';
import 'package:intl/intl.dart';

final _random = Random();

const _authors = ['Alice', 'Bob', 'Charlie', 'David', 'Eve'];
const _emojis = ['😀', '😂', '😍', '🤔', '👍', '🎉', '🚀', '🔥', '💯'];
const _shortTexts = [
  'Ok',
  'Gracias',
  'Nos vemos',
  'Jajaja',
  '¿En serio?',
  'No puede ser',
];
const _longTexts = [
  'Hola, ¿cómo estás? Quería saber si tienes un momento para revisar el documento que te envié ayer. Es bastante urgente.',
  'Recuerda que la reunión de mañana es a las 10:00 AM en la sala de conferencias. Por favor, sé puntual.',
  'Estuve pensando en lo que hablamos y creo que la mejor solución es implementar la nueva API que nos recomendaron. A largo plazo, nos ahorrará mucho tiempo y esfuerzo.',
  'Este es un mensaje de varias líneas para probar el rendimiento del parser.\nSegunda línea del mensaje.\nTercera línea con algunos emojis 🎉🚀.',
];

String mockRealisticMessage({
  required DateTime dateTime,
}) {
  final author = _authors[_random.nextInt(_authors.length)];
  final format = DateFormat('dd/MM/yyyy, HH:mm');
  final dateString = format.format(dateTime);

  String messageBody;

  // Decide if the message should be long or short
  if (_random.nextDouble() < 0.3) { // 30% chance of a long message
    messageBody = _longTexts[_random.nextInt(_longTexts.length)];
  } else {
    messageBody = _shortTexts[_random.nextInt(_shortTexts.length)];
  }

  // Decide if the message should have emojis
  if (_random.nextDouble() < 0.5) { // 50% chance of having emojis
    final emojiCount = _random.nextInt(3) + 1; // 1 to 3 emojis
    for (var i = 0; i < emojiCount; i++) {
      final emoji = _emojis[_random.nextInt(_emojis.length)];
      messageBody += ' $emoji';
    }
  }

  return '$dateString - $author: $messageBody';
}
