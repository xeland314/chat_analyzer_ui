import 'package:flutter_test/flutter_test.dart';
import 'package:chat_analyzer_ui/ui/chat/chat_helpers.dart';

void main() {
  group('getInitials', () {
    test('devuelve iniciales normales', () {
      expect(getInitials('John Doe'), 'JD');
      expect(getInitials('Alice'), 'A');
      expect(getInitials('Bob Marley Smith'), 'BM');
    });

    test('maneja espacios extra', () {
      expect(getInitials('  John   Doe '), 'JD');
      expect(getInitials('  Alice '), 'A');
    });

    test('maneja nombres numéricos (teléfonos)', () {
      expect(getInitials('5551234567'), '567');
      expect(getInitials('+34 600 123 456'), '456');
      expect(getInitials('12'), '12'); // menos de 3 dígitos
    });

    test('mezcla letras y números', () {
      expect(getInitials('John 123'), 'J1');
      expect(getInitials('Alice 7'), 'A7');
    });
  });

  group('colorForName', () {
    test('devuelve un color consistente para un mismo nombre', () {
      final color1 = colorForName('Alice');
      final color2 = colorForName('Alice');
      expect(color1, color2);
    });

    test('devuelve diferentes colores para nombres distintos', () {
      final color1 = colorForName('Alice');
      final color2 = colorForName('Bob');
      expect(color1 != color2, true);
    });

    test('el color no es demasiado claro ni amarillento', () {
      final color = colorForName('Yellow Test');
      // Solo validación de rango aproximado de luminancia
      final luminance = color.computeLuminance();
      expect(luminance <= 0.75, true);
    });
  });
}
