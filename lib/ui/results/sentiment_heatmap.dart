import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'chart_legend_item.dart';
import '../../l10n/app_localizations.dart';

/// Mapa de calor para la tendencia de sentimiento por día.
class SentimentHeatmap extends StatelessWidget {
  final Map<DateTime, double> data;
  final int year;
  final int neutralSentimentValue = 9;
  final int positiveSentimentValue = 1;
  final int negativeSentimentValue = -1;

  const SentimentHeatmap({super.key, required this.data, required this.year});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    if (data.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appLocalizations.sentiment_heatmap_title(year.toString()),
            style: Theme.of(context).textTheme.titleLarge,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(appLocalizations.sentiment_heatmap_no_data),
          ),
        ],
      );
    }

    final sentimentCategoryPerDay = data.map((date, score) {
      int category;
      if (score > 0.05) {
        category = positiveSentimentValue; // Positive
      } else if (score < -0.05) {
        category = negativeSentimentValue; // Negative
      } else {
        category = neutralSentimentValue; // Neutral
      }
      return MapEntry(date, category);
    });

    final scrollController = ScrollController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.sentiment_heatmap_title(year.toString()),
          style: Theme.of(context).textTheme.titleLarge,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 250,
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: HeatMap(
                datasets: sentimentCategoryPerDay,
                startDate: DateTime(year, 1, 1),
                endDate: DateTime(year, 12, 31),
                colorMode: ColorMode.color,
                showText: false,
                showColorTip: true,
                colorsets: {
                  negativeSentimentValue: Colors.red,
                  positiveSentimentValue: Colors.green,
                  neutralSentimentValue: Colors.grey,
                },
                onClick: (date) {
                  final score = data[date] ?? 0.0;
                  final category = sentimentCategoryPerDay[date] ?? 0;
                  String sentimentText = category > 0
                      ? appLocalizations.sentiment_heatmap_positive
                      : category < 0
                      ? appLocalizations.sentiment_heatmap_negative
                      : appLocalizations.sentiment_heatmap_neutral;

                  final snackBar = SnackBar(
                    content: Text(
                      appLocalizations.sentiment_heatmap_snackbar_content(sentimentText, score.toStringAsFixed(2), date.toString().split(' ').first),
                    ),
                    action: SnackBarAction(
                      label: appLocalizations.sentiment_heatmap_close_button,
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: ChartLegendItem(Colors.green, appLocalizations.sentiment_heatmap_positive)),
            Expanded(child: ChartLegendItem(Colors.red, appLocalizations.sentiment_heatmap_negative)),
            Expanded(child: ChartLegendItem(Colors.grey.shade400, appLocalizations.sentiment_heatmap_neutral)),
          ],
        ),
      ],
    );
  }
}
