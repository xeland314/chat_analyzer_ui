import 'dart:math';
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
          'Conversation Threshold (minutes)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Detected natural threshold: ${naturalThreshold.toStringAsFixed(1)} min. Use the slider to adjust.',
        ),
        Slider(
          value: currentThreshold,
          min: 1,
          max: max(360, naturalThreshold * 2), // 6 hours or 2x natural
          divisions: 359,
          label: currentThreshold.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
