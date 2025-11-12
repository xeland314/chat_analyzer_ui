import 'dart:io';
import 'package:test/test.dart';
import 'package:chat_analyzer_ui/src/analysis/chat_parser_rust.dart';
import 'realistic_mock_message.dart';

void main() {
  final parser = ChatParserFFI();
  final results = <Map<String, dynamic>>[];

  setUpAll(() {
    final file = File('performance.md');
    if (!file.existsSync()) {
      file.writeAsStringSync('# Parser Performance Analysis\n\n');
      file.writeAsStringSync('| Message Count | Time (ms) |\n');
      file.writeAsStringSync('|---|---|\n');
    }
    file.writeAsStringSync(
      '\n## Realistic Parser Performance Analysis\n\n',
      mode: FileMode.append,
    );
    file.writeAsStringSync(
      '| Message Count | Time (ms) |\n',
      mode: FileMode.append,
    );
    file.writeAsStringSync('|---|---|\n', mode: FileMode.append);
  });

  tearDownAll(() {
    final file = File('performance.md');
    for (final result in results) {
      file.writeAsStringSync(
        '| ${result['count']} | ${result['time']} |\n',
        mode: FileMode.append,
      );
    }
  });

  void runBenchmark(int messageCount) {
    test(
      'parses $messageCount realistic messages',
      () {
        final startTime = DateTime.now();
        final messages = List.generate(
          messageCount,
          (i) => mockRealisticMessage(
            dateTime: startTime.add(Duration(minutes: i)),
          ),
        );
        final chatContent = messages.join('\n');

        final stopwatch = Stopwatch()..start();
        parser.parse(chatContent);
        stopwatch.stop();

        results.add({
          'count': messageCount,
          'time': stopwatch.elapsedMilliseconds,
        });
      },
      timeout: Timeout(Duration(minutes: 5)),
    );
  }

  // Definimos el factor de la base (1, 10, 100, 1000)
  final factors = [1, 10, 100, 1000];

  // Bucle externo: Itera sobre los factores de 10 (grupos)
  for (final factor in factors) {
    // Bucle interno: Itera sobre los multiplicadores (1 a 9)
    for (var multiplier = 1; multiplier <= 9; multiplier++) {
      final benchmarkValue = factor * multiplier;
      runBenchmark(benchmarkValue);
    }
  }
}
