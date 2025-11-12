import 'package:chat_analyzer_ui/src/models/chat_message.dart'; // Ajusta la ruta

// --- Función Auxiliar para Mockear Mensajes ---
ChatMessage mockMessage(String author, {required int minutesOffset}) {
  return ChatMessage(
    author: author,
    content: 'Test message from $author',
    // Usamos una base de tiempo fija para que los cálculos de duración sean determinísticos.
    dateTime: DateTime(
      2025,
      10,
      30,
      10,
      0,
      0,
    ).add(Duration(minutes: minutesOffset)),
    sentimentScore: 0.0,
  );
}
