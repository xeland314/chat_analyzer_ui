import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

/// Mapa de calor para la actividad de mensajes por día.
class ActivityHeatmap extends StatelessWidget {
  final Map<DateTime, int> data;
  final int year;

  const ActivityHeatmap({super.key, required this.data, required this.year});

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Message Activity ($year)',
          style: Theme.of(context).textTheme.titleLarge,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        if (data.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No message activity for this year.'),
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
                  colorsets: const {1: Colors.indigo},
                  onClick: (date) {
                    final count = data[date] ?? 0;
                    final snackBar = SnackBar(
                      content: Text('$count messages on this day'),
                      action: SnackBarAction(
                        label: 'Close',
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
