import 'package:flutter/material.dart';

/// Un widget pequeño para mostrar la leyenda de un gráfico.
class ChartLegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const ChartLegendItem(this.color, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 4),
        Expanded(child: Text(text, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
