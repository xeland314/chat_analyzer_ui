import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Gráfico de barras para la actividad por hora del día.
class HourlyActivityChart extends StatelessWidget {
  final Map<int, int> data;

  const HourlyActivityChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final entries = List.generate(24, (hour) {
      return BarChartGroupData(
        x: hour,
        barRods: [
          BarChartRodData(
            toY: data[hour]?.toDouble() ?? 0.0,
            color: Colors.teal,
            width: 10,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Most Active Hours',
          style: Theme.of(context).textTheme.titleLarge,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: BarChart(
            BarChartData(
              barGroups: entries,
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final hour = value.toInt();
                      if (hour % 3 == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('${hour}h'),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 28,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.round()} messages',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
