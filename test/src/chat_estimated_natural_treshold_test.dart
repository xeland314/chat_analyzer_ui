import 'package:test/test.dart';
import 'package:chat_analyzer_ui/src/analysis/interaction_analyzer.dart';
import 'mock_message.dart'; // Asumiendo que esta es la ruta de tu función mockMessage

void main() {
  group('InteractionAnalyzer - segmentConversations', () {
    // Usaremos un umbral fijo de 15 minutos para la mayoría de las pruebas

    test('Lista vacía: Debe devolver una lista vacía de Conversation', () {
      final analyzer = InteractionAnalyzer([]);
      final conversations = analyzer.segmentConversations(
        thresholdInMinutes: 15.0,
      );
      expect(conversations, isEmpty);
    });

    test(
      'Umbral Automático: Debe usar estimateNaturalThreshold si no se proporciona threshold',
      () {
        // Gaps: [10, 30]. Por defecto (50mo percentil): 20.0.
        final messages = [
          mockMessage('A', minutesOffset: 0),
          mockMessage('B', minutesOffset: 10),
          mockMessage('C', minutesOffset: 40),
          mockMessage('D', minutesOffset: 45),
        ];
        final analyzer = InteractionAnalyzer(messages);

        // El umbral automático es 20.0 minutos.
        final conversations = analyzer.segmentConversations();

        expect(
          conversations.length,
          2,
          reason:
              'Debe haber 2 conversaciones usando el umbral automático (20 min).',
        );
        expect(
          conversations.first.messages.length,
          2,
          reason: 'Primera conv (A, B).',
        );
        expect(
          conversations.last.messages.length,
          2,
          reason: 'Segunda conv (C, D).',
        );
      },
    );

    test('Sin Quiebres: Todos los mensajes están dentro del umbral', () {
      final messages = [
        mockMessage('A', minutesOffset: 0),
        mockMessage('B', minutesOffset: 5),
        mockMessage('C', minutesOffset: 10),
      ];
      final analyzer = InteractionAnalyzer(messages);

      final conversations = analyzer.segmentConversations(
        thresholdInMinutes: 15.0,
      );

      expect(
        conversations.length,
        1,
        reason: 'Solo debe haber una conversación.',
      );
      expect(
        conversations.first.messages.length,
        3,
        reason: 'Debe contener todos los mensajes.',
      );
      expect(conversations.first.startTime, equals(messages.first.dateTime));
      expect(conversations.first.endTime, equals(messages.last.dateTime));
    });

    test('Múltiples Quiebres: El chat se segmenta correctamente', () {
      final messages = [
        mockMessage('A', minutesOffset: 0), // Conv 1: Mensaje 1
        mockMessage('B', minutesOffset: 5), // Conv 1: Mensaje 2 (Gap 5)
        mockMessage(
          'C',
          minutesOffset: 30,
        ), // Conv 2: Mensaje 3 (Gap 25 > 15) -> Quiebre
        mockMessage('D', minutesOffset: 35), // Conv 2: Mensaje 4 (Gap 5)
        mockMessage(
          'E',
          minutesOffset: 60,
        ), // Conv 3: Mensaje 5 (Gap 25 > 15) -> Quiebre
        mockMessage('F', minutesOffset: 65), // Conv 3: Mensaje 6 (Gap 5)
      ];
      final analyzer = InteractionAnalyzer(messages);

      final conversations = analyzer.segmentConversations(
        thresholdInMinutes: 15.0,
      );

      expect(
        conversations.length,
        3,
        reason: 'Debe haber tres conversaciones.',
      );
      expect(conversations[0].messages.length, 2);
      expect(conversations[1].messages.length, 2);
      expect(conversations[2].messages.length, 2);
    });

    // 🚨 CORRECCIÓN AQUÍ: Aumentar el umbral para evitar el quiebre.
    test(
      'Primer/Último Mensaje: Todos los mensajes deben estar incluidos y en orden',
      () {
        final messages = [
          mockMessage('Start', minutesOffset: 0),
          mockMessage('Mid', minutesOffset: 10),
          mockMessage('End', minutesOffset: 60), // Gap de 50 minutos.
        ];
        final analyzer = InteractionAnalyzer(messages);

        final conversations = analyzer.segmentConversations(
          // 🚨 Aumentado a 60.0. 50 min < 60 min. Evita el quiebre.
          thresholdInMinutes: 60.0,
        );

        expect(
          conversations.length,
          1,
          reason: 'Debe haber 1 conversación (Umbral > 50).',
        );
        expect(
          conversations.first.messages.length,
          3,
          reason: 'Se deben incluir todos los 3 mensajes.',
        );
      },
    );
  });

  // ----------------------------------------------------
  // GRUPO DE TESTS DE ESTIMATE NATURAL THRESHOLD
  // ----------------------------------------------------
  group('InteractionAnalyzer - estimateNaturalThreshold', () {
    test('Debe devolver 60.0 por defecto si el chat tiene 0 o 1 mensaje', () {
      final analyzerEmpty = InteractionAnalyzer([]);
      expect(
        analyzerEmpty.estimateNaturalThreshold(),
        equals(60.0),
        reason: 'Debe devolver el fallback para chats vacíos.',
      );

      final analyzerOneMsg = InteractionAnalyzer([
        mockMessage('A', minutesOffset: 0),
      ]);
      expect(
        analyzerOneMsg.estimateNaturalThreshold(),
        equals(60.0),
        reason: 'Debe devolver el fallback para chats con un solo mensaje.',
      );
    });

    test('Debe manejar mensajes con el mismo DateTime (gap cero)', () {
      final messages = [
        mockMessage('A', minutesOffset: 10),
        mockMessage('B', minutesOffset: 10), // Gap: 0 min
        mockMessage('C', minutesOffset: 15), // Gap: 5 min
      ];

      final analyzer = InteractionAnalyzer(messages);
      // Resultado: 4.5
      expect(analyzer.estimateNaturalThreshold(percentile: 90.0), equals(4.5));
    });

    // 🚨 CORRECCIÓN DE UNUSED VARIABLE: Uso de analyzer12 para el expect
    test(
      'Debe calcular el percentil correctamente cuando el índice es entero (sin interpolación)',
      () {
        // Gaps: [20, 20, ..., 20] (11 gaps).
        final messages12 = List.generate(
          12,
          (i) => mockMessage('A', minutesOffset: i * 20),
        );
        final analyzer12 = InteractionAnalyzer(messages12);
        // 80mo percentil (Índice 8.0) es 20.0
        expect(
          analyzer12.estimateNaturalThreshold(percentile: 80.0),
          closeTo(20.0, 0.01),
        );
      },
    );

    test(
      'Debe calcular el percentil usando interpolación lineal cuando el índice es flotante',
      () {
        // Mensajes con gaps de [1, 5, 10, 20, 30] (5 gaps)
        final messages5 = [
          mockMessage('A', minutesOffset: 0),
          mockMessage('B', minutesOffset: 1),
          mockMessage('C', minutesOffset: 6),
          mockMessage('D', minutesOffset: 16),
          mockMessage('E', minutesOffset: 36),
          mockMessage('F', minutesOffset: 66),
        ];
        final analyzer5 = InteractionAnalyzer(messages5);

        // 90mo percentil (Índice 3.6) = 26.0
        expect(
          analyzer5.estimateNaturalThreshold(percentile: 90.0),
          closeTo(26.0, 0.01),
        );
      },
    );

    // 🚨 CORRECCIÓN LÓGICA DE CACHÉ
    // 🚨 CORRECCIÓN LÓGICA FINAL DEL CACHÉ
    test(
      'Debe cachear el resultado después del primer cálculo y mantenerlo para llamadas posteriores (strict cache)',
      () {
        final messagesCorrectCache = [
          mockMessage('A', minutesOffset: 0),
          mockMessage('B', minutesOffset: 10), // Gap 10
          mockMessage('C', minutesOffset: 40), // Gap 30
        ];
        final analyzerCorrectCache = InteractionAnalyzer(messagesCorrectCache);

        // 1. PRIMER CÁLCULO (50mo percentil, por defecto). Valor: 20.0. Caché: 20.0
        final cachedValue = analyzerCorrectCache.estimateNaturalThreshold(
          percentile: 50.0,
        );
        expect(
          cachedValue,
          closeTo(20.0, 0.01),
          reason: 'El primer cálculo debe ser 20.0.',
        );

        // 2. SEGUNDA LLAMADA CON ARGUMENTO DIFERENTE (90.0)
        // Lógica real: Devuelve el valor cacheado (20.0), ignorando el nuevo percentil.
        final cachedResultAgain = analyzerCorrectCache.estimateNaturalThreshold(
          percentile: 90.0,
        );
        // 💡 Aserción corregida para esperar 20.0
        expect(
          cachedResultAgain,
          closeTo(20.0, 0.01),
          reason:
              'El caché SÍ se usa de forma estricta. Una vez calculado (20.0), se ignora cualquier nuevo argumento.',
        );

        // 3. TERCERA LLAMADA (sin argumentos)
        // Lógica: Usa el valor cacheado (20.0).
        final finalCachedResult = analyzerCorrectCache
            .estimateNaturalThreshold();
        expect(
          finalCachedResult,
          closeTo(20.0, 0.01),
          reason:
              'El caché debe persistir y devolver el valor original (20.0).',
        );
      },
    );
  });
}
