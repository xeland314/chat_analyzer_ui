import 'dart:math';
import 'package:chat_analyzer_ui/ui/common/time_to_text.dart';
import 'package:flutter/material.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conversation Threshold',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Detected natural threshold: ${formatDuration(Duration(seconds: (naturalThreshold * 60).toInt()))}. Use the slider to adjust.',
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
