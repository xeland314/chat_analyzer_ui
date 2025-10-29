import 'package:flutter/material.dart';
import 'export_service.dart';
import '../../l10n/app_localizations.dart';

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
    final appLocalizations = AppLocalizations.of(context)!;
    return FloatingActionButton(
      onPressed: () {
        ExportService.exportAndShareWidget(
          repaintBoundaryKey,
          appLocalizations.name,
          fileName,
          context,
        );
      },
      child: const Icon(Icons.share),
    );
  }
}
