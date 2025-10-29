import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import '../../l10n/app_localizations.dart';

/// Mapa de calor para la actividad de mensajes por día.
class ActivityHeatmap extends StatelessWidget {
  final Map<DateTime, int> data;
  final int year;

  const ActivityHeatmap({super.key, required this.data, required this.year});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final scrollController = ScrollController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.activity_heatmap_message_activity(year.toString()),
          style: Theme.of(context).textTheme.titleLarge,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        if (data.isEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(appLocalizations.activity_heatmap_no_message_activity),
          )
        else
          SizedBox(
            height: 250,
            child: Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                child: HeatMap(
                  datasets: data,
                  startDate: DateTime(year, 1, 1),
                  endDate: DateTime(year, 12, 31),
                  colorMode: ColorMode.opacity,
                  showText: false,
                  colorsets: {1: Colors.teal.shade900},
                  onClick: (date) {
                    final count = data[date] ?? 0;
                    final snackBar = SnackBar(
                      content: Text(
                        appLocalizations.activity_heatmap_messages_on_date(count.toString(), date.toString().split(' ').first),
                      ),
                      action: SnackBarAction(
                        label: appLocalizations.activity_heatmap_close_button,
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
      ],
    );
  }
}
