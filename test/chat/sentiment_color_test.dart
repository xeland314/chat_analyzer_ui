import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_analyzer_ui/ui/chat/chat_helpers.dart';

void main() {
  group('sentimentColor', () {
    test('devuelve verde para score positivo', () {
      expect(sentimentColor(0.1), Colors.green);
      expect(sentimentColor(3.5), Colors.green);
    });

    test('devuelve rojo para score negativo', () {
      expect(sentimentColor(-0.1), Colors.red);
      expect(sentimentColor(-5.0), Colors.red);
    });

    test('devuelve gris para score neutral', () {
      expect(sentimentColor(0), Colors.grey);
    });
  });
}
