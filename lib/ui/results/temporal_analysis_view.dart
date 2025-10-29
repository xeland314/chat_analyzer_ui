import 'package:flutter/material.dart';
import '../../src/models/chat_participant.dart';
import 'sentiment_heatmap.dart';
import 'activity_heatmap.dart';
import '../../l10n/app_localizations.dart';

/// Muestra el análisis temporal de la actividad y el sentimiento.
///
/// Aún es Stateful para gestionar el año seleccionado.
class TemporalAnalysisView extends StatefulWidget {
  final ChatParticipant participant;

  const TemporalAnalysisView({super.key, required this.participant});

  @override
  State<TemporalAnalysisView> createState() => _TemporalAnalysisViewState();
}

class _TemporalAnalysisViewState extends State<TemporalAnalysisView> {
  late int _selectedYear;
  late List<int> _availableYears;

  @override
  void initState() {
    super.initState();
    final years = <int>{};
    years.addAll(widget.participant.messageCountPerDay.keys.map((d) => d.year));
    years.addAll(
      widget.participant.sentimentScorePerDay.keys.map((d) => d.year),
    );

    _availableYears = years.toList()..sort((a, b) => b.compareTo(a));

    _selectedYear = _availableYears.isNotEmpty
        ? _availableYears.first
        : DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    if (_availableYears.isEmpty &&
        widget.participant.messageCountByHour.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                appLocalizations.temporal_analysis_view_title,
                style: Theme.of(context).textTheme.headlineSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_availableYears.length > 1) _buildYearSelector(),
          ],
        ),
        const Divider(),
        if (_availableYears.isNotEmpty)
          Column(
            children: [
              const SizedBox(height: 16),
              ActivityHeatmap(
                data: Map.fromEntries(
                  widget.participant.messageCountPerDay.entries.where(
                    (entry) => entry.key.year == _selectedYear,
                  ),
                ),
                year: _selectedYear,
              ),
              const SizedBox(height: 24),
              SentimentHeatmap(
                data: Map.fromEntries(
                  widget.participant.sentimentScorePerDay.entries.where(
                    (entry) => entry.key.year == _selectedYear,
                  ),
                ),
                year: _selectedYear,
              ),
              const SizedBox(height: 24),
            ],
          ),
      ],
    );
  }

  Widget _buildYearSelector() {
    return DropdownButton<int>(
      value: _selectedYear,
      items: _availableYears.map((year) {
        return DropdownMenuItem<int>(value: year, child: Text(year.toString()));
      }).toList(),
      onChanged: (newYear) {
        if (newYear != null) {
          setState(() {
            _selectedYear = newYear;
          });
        }
      },
    );
  }
}
