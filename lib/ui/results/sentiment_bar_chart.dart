import 'package:flutter/material.dart';
import 'chart_legend_item.dart';
import '../../l10n/app_localizations.dart';

class SentimentBarChart extends StatelessWidget {
  final Map<String, int> sentimentData;

  const SentimentBarChart({super.key, required this.sentimentData});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final positive = sentimentData['Positive']!;
    final negative = sentimentData['Negative']!;
    final neutral = sentimentData['Neutral']!;
    final total = positive + negative + neutral;

    if (total == 0) return const SizedBox.shrink();

    final positivePercent = positive / total;
    final negativePercent = negative / total;
    final neutralPercent = neutral / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.sentiment_bar_chart_title,
          style: Theme.of(context).textTheme.titleLarge,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 30,
            child: Row(
              children: [
                if (positive > 0)
                  Expanded(
                    flex: (positivePercent * 100).round(),
                    child: Tooltip(
                      message:
                          appLocalizations.sentiment_bar_chart_positive_tooltip((positivePercent * 100).toStringAsFixed(2)),
                      child: Container(
                        color: Colors.green,
                        child: Center(
                          child: positivePercent > 0.1
                              ? Text(
                                  '${(positivePercent * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                if (negative > 0)
                  Expanded(
                    flex: (negativePercent * 100).round(),
                    child: Tooltip(
                      message:
                          appLocalizations.sentiment_bar_chart_negative_tooltip((negativePercent * 100).toStringAsFixed(2)),
                      child: Container(
                        color: Colors.red,
                        child: Center(
                          child: negativePercent > 0.1
                              ? Text(
                                  '${(negativePercent * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                if (neutral > 0)
                  Expanded(
                    flex: (neutralPercent * 100).round(),
                    child: Tooltip(
                      message:
                          appLocalizations.sentiment_bar_chart_neutral_tooltip((neutralPercent * 100).toStringAsFixed(2)),
                      child: Container(
                        color: Colors.grey,
                        child: Center(
                          child: neutralPercent > 0.1
                              ? Text(
                                  '${(neutralPercent * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ChartLegendItem(Colors.green, appLocalizations.sentiment_bar_chart_positive_legend(positive.toString())),
            ),
            Expanded(child: ChartLegendItem(Colors.red, appLocalizations.sentiment_bar_chart_negative_legend(negative.toString()))),
            Expanded(child: ChartLegendItem(Colors.grey, appLocalizations.sentiment_bar_chart_neutral_legend(neutral.toString()))),
          ],
        ),
      ],
    );
  }
}
