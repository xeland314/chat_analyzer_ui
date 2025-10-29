import 'dart:math';
import 'package:chat_analyzer_ui/ui/common/time_to_text.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Deslizador para ajustar el umbral de conversación.
class ThresholdSlider extends StatelessWidget {
  final double naturalThreshold;
  final double currentThreshold;
  final ValueChanged<double> onChanged;

  const ThresholdSlider({
    super.key,
    required this.naturalThreshold,
    required this.currentThreshold,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.threshold_slider_title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          appLocalizations.threshold_slider_description(formatDuration(Duration(seconds: (naturalThreshold * 60).toInt()))),
        ),
        Slider(
          value: currentThreshold,
          min: 1,
          max: max(360, naturalThreshold * 2), // 6 hours or 2x natural
          divisions: 359,
          label: formatDuration(
            Duration(seconds: (currentThreshold * 60).toInt()),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
