import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'chart_legend_item.dart';

/// Gráfico de barras que muestra quién inicia y quién termina las conversaciones.
class StartersEndersChart extends StatelessWidget {
  final Map<String, int> starters;
  final Map<String, int> enders;

  const StartersEndersChart({
    super.key,
    required this.starters,
    required this.enders,
  });

  @override
  Widget build(BuildContext context) {
    final participants = (starters.keys.toSet()..addAll(enders.keys)).toList();
    if (participants.isEmpty) return const SizedBox.shrink();

    final barGroups = participants.asMap().entries.map((entry) {
      final index = entry.key;
      final name = entry.value;
      final starterCount = starters[name]?.toDouble() ?? 0.0;
      final enderCount = enders[name]?.toDouble() ?? 0.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: starterCount, color: Colors.teal, width: 12),
          BarChartRodData(toY: enderCount, color: Colors.amber, width: 12),
        ],
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conversation Starters & Enders',
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
                      if (index >= 0 && index < participants.length) {
                        return Text(
                          participants[index].substring(
                            0,
                            min(participants[index].length, 3),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: ChartLegendItem(Colors.teal, 'Started')),
            const SizedBox(width: 16),
            Expanded(child: ChartLegendItem(Colors.amber, 'Ended')),
          ],
        ),
      ],
    );
  }
}
