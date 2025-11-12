import 'package:flutter_test/flutter_test.dart';
import 'package:chat_analyzer_ui/src/analysis/chat_parser_rust.dart';
import 'package:chat_analyzer_ui/src/models/chat_message.dart';
import 'package:chat_analyzer_ui/src/models/chat_participant.dart';

// Mock básico para simular la lógica de ChatAnalysis
void main() {
  late ChatParserFFI parser;

  setUp(() {
    // Inicializar el parser antes de cada prueba
    parser = ChatParserFFI();
  });

  group('ChatParser - Funcionalidad Básica', () {
    test('Debe analizar un chat simple con dos autores', () {
      const content = '''
1/1/22, 10:00 - Autor1: Hola, ¿cómo estás?
1/1/22, 10:01 - Autor2: ¡Muy bien! Gracias por preguntar.
''';
      final analysis = parser.parse(content);

      expect(analysis.participants.length, 2);
      expect(analysis.participants.any((p) => p.name == 'Autor1'), isTrue);
      expect(analysis.participants.any((p) => p.name == 'Autor2'), isTrue);

      final autor1 = analysis.participants.firstWhere(
        (p) => p.name == 'Autor1',
      );
      expect(autor1.messages.length, 1);
      expect(autor1.messages.first.content, 'Hola, ¿cómo estás?');

      final autor2 = analysis.participants.firstWhere(
        (p) => p.name == 'Autor2',
      );
      expect(autor2.messages.length, 1);
      expect(
        autor2.messages.first.content,
        '¡Muy bien! Gracias por preguntar.',
      );
    });

    test('Debe manejar mensajes multilínea', () {
      const content = '''
1/1/22, 11:00 - AutorA: Este es un mensaje
que ocupa varias
líneas.
1/1/22, 11:01 - AutorB: Ok.
''';
      final analysis = parser.parse(content);

      final autorA = analysis.participants.firstWhere(
        (p) => p.name == 'AutorA',
      );
      expect(autorA.messages.length, 1);
      expect(
        autorA.messages.first.content,
        'Este es un mensaje\nque ocupa varias\nlíneas.',
      );
    });

    test('Debe ignorar los mensajes del sistema conocidos', () {
      const content = '''
1/1/22, 12:00 - AutorX: Mensaje 1
1/1/22, 12:01 - AutorY: <Multimedia omitido>
Los mensajes y llamadas están cifrados de extremo a extremo.
1/1/22, 12:02 - AutorX: Mensaje 2
''';
      final analysis = parser.parse(content);

      final autorX = analysis.participants.firstWhere(
        (p) => p.name == 'AutorX',
      );
      // Solo debería contar los dos mensajes reales de AutorX
      expect(autorX.messages.length, 2);
    });

    test('Debe manejar el formato de fecha de 4 dígitos (d/M/yyyy)', () {
      const content = '25/12/2023, 15:30 - AutorZ: Navidad';
      final analysis = parser.parse(content);

      expect(analysis.participants.length, 1);
      expect(
        analysis.participants.first.messages.first.dateTime,
        DateTime.parse('2023-12-25 15:30:00.000'),
      );
    });

    test('Debe manejar el formato de fecha de 2 dígitos (d/M/yy)', () {
      const content = '1/5/24, 08:00 - AutorZ: Mañana';
      final analysis = parser.parse(content);

      expect(analysis.participants.length, 1);
      // Asume que '24' es el año 2024
      expect(
        analysis.participants.first.messages.first.dateTime,
        DateTime.parse('2024-05-01 08:00:00.000'),
      );
    });
  });

  group('ChatParser - Casos Extremos y de Borde', () {
    test('Debe manejar contenido vacío', () {
      const content = '';
      final analysis = parser.parse(content);
      expect(analysis.participants.length, 0);
      expect(analysis.allMessagesChronological.length, 0);
    });

    test('Debe manejar solo mensajes del sistema', () {
      const content =
          'Los mensajes y llamadas están cifrados de extremo a extremo.\n<Multimedia omitido>\n';
      final analysis = parser.parse(content);
      expect(analysis.participants.length, 0);
      expect(analysis.allMessagesChronological.length, 0);
    });

    test('Debe manejar un mensaje que contiene el separador de línea', () {
      // El patrón '^(\d{1,2}/\d{1,2}/\d{2,4}, \d{1,2}:\d{2}) - ([^:]+): (.+)'
      // debería prevenir que esto se interprete como una nueva línea de mensaje.
      const content = '''
1/1/22, 13:00 - AutorA: Esto no es una nueva línea - AutorB: Es solo texto.
1/1/22, 13:01 - AutorB: Nuevo mensaje.
''';
      final analysis = parser.parse(content);

      final autorA = analysis.participants.firstWhere(
        (p) => p.name == 'AutorA',
      );
      expect(autorA.messages.length, 1);
      expect(
        autorA.messages.first.content,
        'Esto no es una nueva línea - AutorB: Es solo texto.',
      );
      expect(analysis.allMessagesChronological.length, 2);
    });

    test(
      'Debe manejar una línea mal formada como continuación del mensaje anterior',
      () {
        const content = '''
1/1/22, 14:00 - AutorA: Mensaje inicial
Una línea sin el formato de fecha-hora
1/1/22, 14:01 - AutorB: Fin.
''';
        final analysis = parser.parse(content);

        final autorA = analysis.participants.firstWhere(
          (p) => p.name == 'AutorA',
        );
        expect(autorA.messages.length, 1);
        expect(
          autorA.messages.first.content,
          'Mensaje inicial\nUna línea sin el formato de fecha-hora',
        );
      },
    );
  });

  group('ChatParticipant - Análisis de Métricas', () {
    // Nota: El score de sentimiento se prueba indirectamente ya que el mock de Sentiment no está controlado.
    // Asumiremos que dart_sentiment funciona correctamente.

    // Se necesita un ChatAnalysis con mensajes para estas pruebas.
    // En un caso real, necesitarías una forma de mockear o inicializar tus modelos.
    // Usaremos un ChatParticipant con mensajes "hardcodeados" para simplificar.

    late ChatParticipant participant;

    setUp(() {
      participant = ChatParticipant(
        name: 'TestUser',
        messages: [
          ChatMessage(
            author: 'TestUser',
            content: 'Hola! Qué buen día, me encanta 😄',
            dateTime: DateTime(2023, 10, 29, 10, 0),
            sentimentScore: 2.0, // Positivo
          ),
          ChatMessage(
            author: 'TestUser',
            content: 'Esto es malo, qué desastre',
            dateTime: DateTime(2023, 10, 29, 11, 0),
            sentimentScore: -1.0, // Negativo
          ),
          ChatMessage(
            author: 'TestUser',
            content: '<Multimedia omitido>',
            dateTime: DateTime(2023, 10, 30, 9, 0),
            sentimentScore: 0.0, // Neutral
          ),
          ChatMessage(
            author: 'TestUser',
            content: 'Ok, es neutral',
            dateTime: DateTime(2023, 10, 30, 15, 0),
            sentimentScore: 0.0, // Neutral
          ),
        ],
      );
    });

    test('messageCount debe ser correcto', () {
      expect(participant.messageCount, 4);
    });

    test('multimediaCount debe ser correcto', () {
      expect(participant.multimediaCount, 1);
    });

    test('messagesByDate debe agrupar por día', () {
      expect(participant.messagesByDate.length, 2); // 29/10 y 30/10
      expect(participant.messagesByDate[DateTime(2023, 10, 29)]!.length, 2);
      expect(participant.messagesByDate[DateTime(2023, 10, 30)]!.length, 2);
    });

    test('messageCountByHour debe contar por hora', () {
      expect(participant.messageCountByHour.length, 4); // 10, 11, 9, 15
      expect(participant.messageCountByHour[10], 1);
      expect(participant.messageCountByHour[9], 1);
    });

    test('sentimentAnalysis debe contar positivos, negativos y neutrales', () {
      final analysis = participant.sentimentAnalysis;
      expect(analysis['Positive'], 1);
      expect(analysis['Negative'], 1);
      expect(analysis['Neutral'], 2);
    });

    test('emojiFrequency debe contar los emojis correctamente', () {
      final frequency = participant.emojiFrequency;
      expect(frequency['😄'], 1);
      expect(frequency.length, 1);
    });

    test('wordFrequency debe excluir stopwords y mensajes multimedia', () {
      final frequency = participant.wordFrequency;
      // 'buen' (1), 'día' (1), 'encanta' (1), 'malo' (1), 'desastre' (1), 'ok' (1), 'neutral' (1)
      // 'Hola', 'Qué', 'es', 'qué', '<Multimedia omitido>' y 'es' se excluyen (o se eliminan al normalizar)
      // 'el' (artículo), 'la' (artículo) no están en las palabras de ejemplo, pero se asume que se excluirían.
      expect(frequency['buen'], 1, reason: 'Debe contar "buen"');
      expect(
        frequency['día'],
        1,
        reason: 'Debe contar "día" después de limpiar la coma',
      );
      expect(
        frequency['hola'],
        1,
        reason: 'Debe contar "hola" después de limpiar la exclamación',
      );
      expect(
        frequency.containsKey('esto'),
        isFalse,
        reason: 'Debe excluir la stopword "esto"',
      );
      expect(
        frequency.containsKey('<multimedia'),
        isFalse,
        reason: 'Debe excluir el token multimedia',
      ); // 'esto' está en stopwords_spanish.dart
    });
  });
}
