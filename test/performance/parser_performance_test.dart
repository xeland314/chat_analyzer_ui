import 'dart:io';
import 'package:test/test.dart';
import 'package:chat_analyzer_ui/src/analysis/chat_parser.dart';
import '../src/mock_message.dart';

void main() {
  final parser = ChatParserBatchOptimized();
  final results = <Map<String, dynamic>>[];

  setUpAll(() {
    // Create the markdown file and write the header
    final file = File('performance.md');
    file.writeAsStringSync('# Parser Performance Analysis\n\n');
    file.writeAsStringSync(
      '| Message Count | Time (ms) |\n',
      mode: FileMode.append,
    );
    file.writeAsStringSync('|---|---|\n', mode: FileMode.append);
  });

  tearDownAll(() {
    // Write the results to the markdown file
    final file = File('performance.md');
    for (final result in results) {
      file.writeAsStringSync(
        '| ${result['count']} | ${result['time']} |\n',
        mode: FileMode.append,
      );
    }
  });

  void runBenchmark(int messageCount) {
    test('parses $messageCount messages', () {
      final messages = List.generate(
        messageCount,
        (i) => mockMessage('User', minutesOffset: i).toString(),
      );
      final chatContent = messages.join('\n');

      final stopwatch = Stopwatch()..start();
      parser.parse(chatContent);
      stopwatch.stop();

      results.add({
        'count': messageCount,
        'time': stopwatch.elapsedMilliseconds,
      });
    });
  }

  runBenchmark(10);
  runBenchmark(50);
  runBenchmark(100);
  runBenchmark(500);
  runBenchmark(1000);
  runBenchmark(5000);
  runBenchmark(10000);
}
