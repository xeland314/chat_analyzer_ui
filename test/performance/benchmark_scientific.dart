import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:chat_analyzer_ui/src/analysis/chat_parser_rust.dart';
import 'package:chat_analyzer_ui/src/analysis/chat_parser.dart';
import 'realistic_mock_message.dart';

// Extensión para formateo de números (similar a toFixed en JS)
extension on num {
  String toFixed(int fractionDigits) => toStringAsFixed(fractionDigits);
}

// Función para generar el contenido del chat de prueba
String generateTestData(int messageCount, DateTime startTime) {
  final messages = List.generate(
    messageCount,
    (i) => mockRealisticMessage(dateTime: startTime.add(Duration(minutes: i))),
  );
  return messages.join('\n');
}

// Inicialización de Parsers (instancias fuera de main si son necesarias para FFI)
final rustParser = ChatParserFFI();
final dartParser = ChatParserOptimized();

void parseRust(String data) {
  rustParser.parse(data);
}

void parseDart(String data) {
  dartParser.parse(data);
}

void main() async {
  debugPrint('🔬 Iniciando Benchmark Científico...');

  // --- Configuración ---
  const warmupRuns = 5;
  const measurementRuns = 20;
  const messageCount = 50000;

  final startTime = DateTime.now();
  final testData = generateTestData(messageCount, startTime);

  final results = <String, List<int>>{'dart': [], 'rust': []};

  // --- Calentamiento (Warm-up) ---
  debugPrint('\n🔥 Calentando los JIT y FFI ($warmupRuns ejecuciones)...');
  for (var i = 0; i < warmupRuns; i++) {
    parseDart(testData);
    parseRust(testData);
  }

  // --- Forzar Recolección de Basura (GC) ---
  debugPrint('🗑️ Forzando GC...');
  // Esto ayuda a reducir la influencia de la recolección de basura en las mediciones
  await Future.delayed(Duration(seconds: 2));

  // --- Mediciones (Alternadas para evitar sesgos) ---
  debugPrint('\n⏱️ Midiendo ($measurementRuns ejecuciones por parser)...');
  for (var i = 0; i < measurementRuns; i++) {
    // Dart Measurement
    final sw1 = Stopwatch()..start();
    parseDart(testData);
    sw1.stop();
    results['dart']!.add(sw1.elapsedMilliseconds);

    // Pequeño delay para separar las mediciones
    await Future.delayed(Duration(milliseconds: 100));

    // Rust Measurement
    final sw2 = Stopwatch()..start();
    parseRust(testData);
    sw2.stop();
    results['rust']!.add(sw2.elapsedMilliseconds);

    // Pequeño delay
    await Future.delayed(Duration(milliseconds: 100));

    stdout.write('  Run ${i + 1}/$measurementRuns completada...\r');
  }
  debugPrint('\n✅ Mediciones completadas.');

  // --- Análisis Estadístico ---
  debugPrint('\n\n=== RESULTADOS ESTADÍSTICOS ($messageCount Mensajes) ===');

  // Guardamos los resultados para la conclusión
  double dartMean = 0;
  double rustMean = 0;

  results.forEach((name, times) {
    final mean = times.reduce((a, b) => a + b) / times.length;
    final variance =
        times.map((t) => pow(t - mean, 2)).reduce((a, b) => a + b) /
        times.length;
    final stdDev = sqrt(variance);

    if (name == 'dart') dartMean = mean;
    if (name == 'rust') rustMean = mean;

    debugPrint('\n[${name.toUpperCase()} Parser]:');
    debugPrint('  - Media (Mean): ${mean.toFixed(2)}ms');
    debugPrint('  - Desv. Estándar (Std Dev): ${stdDev.toFixed(2)}ms');
    debugPrint('  - Mínimo (Min): ${times.reduce(min)}ms');
    debugPrint('  - Máximo (Max): ${times.reduce(max)}ms');
    debugPrint(
      '  - Coeficiente de Variación (CV): ${(stdDev / mean * 100).toFixed(1)}%',
    );
  });

  // --- Conclusión (T-test simplificado) ---
  debugPrint('\n--- CONCLUSIÓN ---');
  final diff = (dartMean - rustMean).abs();

  // Criterio de "significancia" simplificado (adaptado del código original)
  const significanceThreshold = 50.0; // 50ms de diferencia

  if (diff < significanceThreshold) {
    debugPrint('❓ Diferencia NO significativa (${diff.toFixed(1)}ms).');
    debugPrint(
      'Ambos son estadísticamente equivalentes en rendimiento para esta carga de trabajo.',
    );
  } else if (dartMean < rustMean) {
    debugPrint('🎯 Dart es significativamente más rápido.');
    debugPrint(
      'Diferencia: ${diff.toFixed(1)}ms (${(diff / rustMean * 100).toFixed(1)}% más rápido que Rust).',
    );
  } else {
    debugPrint('🦀 Rust es significativamente más rápido.');
    debugPrint(
      'Diferencia: ${diff.toFixed(1)}ms (${(diff / dartMean * 100).toFixed(1)}% más rápido que Dart).',
    );
  }
}
