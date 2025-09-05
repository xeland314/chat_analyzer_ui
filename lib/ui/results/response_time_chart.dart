import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Gráfico de barras que muestra el tiempo de respuesta promedio.
class ResponseTimeChart extends StatelessWidget {
  final Map<String, Duration> responseTimes;

  const ResponseTimeChart({super.key, required this.responseTimes});

  @override
  Widget build(BuildContext context) {
    final entries = responseTimes.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (entries.isEmpty) return const SizedBox.shrink();

    final barGroups = entries.asMap().entries.map((entry) {
      final index = entry.key;
      final durationInMinutes = entry.value.value.inSeconds / 60.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: durationInMinutes,
            color: Colors.teal,
            width: 14,
          ),
        ],
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Average Response Time (minutes)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: barGroups,
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < entries.length) {
                        final name = entries[index].key;
                        return Text(name.substring(0, min(name.length, 3)));
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
