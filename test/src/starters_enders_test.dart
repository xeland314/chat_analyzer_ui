import 'package:test/test.dart';
import 'package:chat_analyzer_ui/src/analysis/interaction_analyzer.dart';
import 'package:chat_analyzer_ui/src/models/chat_message.dart';
import 'mock_message.dart'; // Importamos la función auxiliar mockMessage

// --- Función Auxiliar para Generar Conversaciones Mockeables ---
Conversation mockConversation(List<String> authors, {int startOffset = 0}) {
  final messages = <ChatMessage>[];
  var currentOffset = startOffset;

  for (final author in authors) {
    messages.add(mockMessage(author, minutesOffset: currentOffset));
    currentOffset += 5; // Simular un pequeño gap de 5 minutos entre mensajes
  }

  return Conversation(messages: messages);
}
// -----------------------------------------------------------------

void main() {
  group('InteractionAnalyzer - D. Métodos de Análisis de Conversación', () {
    // --- Escenario de Prueba ---
    // Usaremos 3 conversaciones con diferentes patrones de inicio/fin.

    // Conv 1: Alice -> Bob -> Alice. (Inicia: Alice, Termina: Alice)
    final conv1 = mockConversation(['Alice', 'Bob', 'Alice'], startOffset: 0);

    // Conv 2: Charlie -> Alice -> Bob. (Inicia: Charlie, Termina: Bob)
    final conv2 = mockConversation([
      'Charlie',
      'Alice',
      'Bob',
    ], startOffset: 30);

    // Conv 3: Charlie -> Charlie. (Inicia: Charlie, Termina: Charlie)
    final conv3 = mockConversation(['Charlie', 'Charlie'], startOffset: 60);

    final allConversations = [conv1, conv2, conv3];

    // ------------------------------------------------------------
    // Test: calculateConversationStarters
    // ------------------------------------------------------------
    test(
      'calculateConversationStarters debe contar correctamente los inicios por autor',
      () {
        final analyzer = InteractionAnalyzer([]);

        final starters = analyzer.calculateConversationStarters(
          allConversations,
        );

        // 🚨 CORRECCIÓN AQUÍ: Eliminamos 'Bob': 0.0 ya que el código solo devuelve entradas > 0.
        final expectedStarters = {
          'Alice': 1, // Inicia Conv 1
          'Charlie': 2, // Inicia Conv 2 y Conv 3
        };

        expect(
          starters,
          equals(expectedStarters),
          reason:
              'El conteo debe ser exacto y solo incluir autores con inicios > 0.',
        );
        // Eliminamos la aserción de longitud, ya que 'equals' es suficiente.
      },
    );

    // ------------------------------------------------------------
    // Test: calculateConversationEnders
    // ------------------------------------------------------------
    test(
      'calculateConversationEnders debe contar correctamente los cierres por autor',
      () {
        final analyzer = InteractionAnalyzer([]);

        final enders = analyzer.calculateConversationEnders(allConversations);

        final expectedEnders = {
          'Alice': 1, // Termina Conv 1
          'Bob': 1, // Termina Conv 2
          'Charlie': 1, // Termina Conv 3
        };

        expect(
          enders,
          equals(expectedEnders),
          reason: 'El conteo de cierres debe ser exacto.',
        );
      },
    );
  });
}
