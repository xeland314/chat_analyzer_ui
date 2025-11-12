import 'package:test/test.dart';
import 'package:chat_analyzer_ui/src/analysis/interaction_analyzer.dart';
import 'mock_message.dart';

void main() {
  group('InteractionAnalyzer - Inicialización y Ordenamiento', () {
    // Crear mensajes desordenados intencionalmente
    final messageA = mockMessage('Charlie', minutesOffset: 30); // Último
    final messageB = mockMessage('Beta', minutesOffset: 10); // Segundo
    final messageC = mockMessage('Alpha', minutesOffset: 5); // Primero

    final unsortedMessages = [messageA, messageB, messageC];

    test(
      'El constructor debe ordenar correctamente la lista interna de mensajes por fecha',
      () {
        // Act
        final analyzer = InteractionAnalyzer(unsortedMessages);

        // ----------------------------------------------------------------------------------
        // ⭐ Prueba indirecta: Verificamos que el cálculo del umbral (que depende del orden) sea correcto.
        // Gaps esperados (en orden C, B, A):
        // 1. (10 - 5) = 5 minutos
        // 2. (30 - 10) = 20 minutos
        // Gaps ordenados: [5.0, 20.0].
        // Cálculo del 90mo percentil: 5 * (1 - 0.9) + 20 * 0.9 = 18.5
        // ----------------------------------------------------------------------------------
        final threshold = analyzer.estimateNaturalThreshold(percentile: 90.0);

        expect(
          threshold,
          equals(18.5),
          reason:
              'El cálculo del umbral confirma que la lista de mensajes se ordenó cronológicamente (C, B, A).',
        );
      },
    );

    test('Debe manejar una lista de mensajes vacía sin errores', () {
      final analyzer = InteractionAnalyzer([]);
      // Prueba un método que depende del estado interno para asegurar que no falla.
      expect(
        analyzer.estimateNaturalThreshold(),
        equals(60.0),
        reason: 'Debe devolver el valor por defecto para chats vacíos.',
      );
    });
  });
}
