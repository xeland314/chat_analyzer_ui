import 'package:flutter_test/flutter_test.dart';
import 'package:chat_analyzer_ui/ui/common/time_to_text.dart';

void main() {
  group('formatDuration', () {
    test('should return the correct format for days and hours', () {
      const duration = Duration(days: 2, hours: 5, minutes: 30, seconds: 45);
      expect(formatDuration(duration), '2d 5h');
    });

    test('should return the correct format for days and minutes', () {
      const duration = Duration(days: 2, minutes: 30, seconds: 45);
      expect(formatDuration(duration), '2d 30min');
    });

    test('should return the correct format for days and seconds', () {
      const duration = Duration(days: 2, seconds: 45);
      expect(formatDuration(duration), '2d 45s');
    });

    test('should return the correct format for hours and minutes', () {
      const duration = Duration(hours: 3, minutes: 15, seconds: 20);
      expect(formatDuration(duration), '3h 15min');
    });

    test('should return the correct format for hours and seconds', () {
      const duration = Duration(hours: 3, seconds: 20);
      expect(formatDuration(duration), '3h 20s');
    });

    test('should return the correct format for minutes and seconds', () {
      const duration = Duration(minutes: 10, seconds: 50);
      expect(formatDuration(duration), '10min 50s');
    });

    test('should return the correct format for seconds', () {
      const duration = Duration(seconds: 30);
      expect(formatDuration(duration), '30s');
    });
  });
}
