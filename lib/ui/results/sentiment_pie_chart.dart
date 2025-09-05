import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'chart_legend_item.dart';

/// Muestra un gráfico de tarta de análisis de sentimiento.
class SentimentPieChart extends StatelessWidget {
  final Map<String, int> sentimentData;

  const SentimentPieChart({super.key, required this.sentimentData});

  @override
  Widget build(BuildContext context) {
    final positive = sentimentData['Positive']!;
    final negative = sentimentData['Negative']!;
    final neutral = sentimentData['Neutral']!;
    final total = positive + negative + neutral;

    if (total == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sentiment Analysis',
          style: Theme.of(context).textTheme.titleLarge,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 40),
        SizedBox(
          height: 150,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: Colors.green,
                  value: positive.toDouble(),
                  title: '${(positive / total * 100).toStringAsFixed(0)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.red,
                  value: negative.toDouble(),
                  title: '${(negative / total * 100).toStringAsFixed(0)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.grey,
                  value: neutral.toDouble(),
                  title: '${(neutral / total * 100).toStringAsFixed(0)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ChartLegendItem(Colors.green, 'Positive: $positive'),
            ),
            Expanded(child: ChartLegendItem(Colors.red, 'Negative: $negative')),
            Expanded(child: ChartLegendItem(Colors.grey, 'Neutral: $neutral')),
          ],
        ),
      ],
    );
  }
}
