import 'package:flutter/material.dart';
import 'export_service.dart';

class ExportButton extends StatelessWidget {
  final GlobalKey repaintBoundaryKey;
  final String fileName;

  const ExportButton({
    super.key,
    required this.repaintBoundaryKey,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        ExportService.exportAndShareWidget(
          repaintBoundaryKey,
          'C.A. xeland314',
          fileName,
          context,
        );
      },
      child: const Icon(Icons.share),
    );
  }
}
