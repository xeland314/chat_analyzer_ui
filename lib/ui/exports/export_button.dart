import 'package:flutter/material.dart';
import 'export_service.dart';
import '../../l10n/app_localizations.dart';

/// A floating export button that shows a small menu with available export formats.
/// Keeps the same constructor signature so replacing previous usages is trivial.
class ExportButton extends StatelessWidget {
  final GlobalKey repaintBoundaryKey;
  final String fileName;
  final Map<String, dynamic>? dataMap;

  const ExportButton({
    super.key,
    required this.repaintBoundaryKey,
    required this.fileName,
    this.dataMap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return FloatingActionButton(
      onPressed: () async {
        // Quick action: export as TOON by default if we have data
        if (dataMap != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.export_button_label} — ${loc.export_toon}')));
          await ExportService.exportData(dataMap!, 'toon', fileName, context);
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.export_no_data_provided)));
      },
      child: PopupMenuButton<String>(
        tooltip: loc.export_button_label,
        icon: const Icon(Icons.share),
        onSelected: (value) async {
          // If parent provided a structured data map, we can export data
          if (dataMap != null) {
            await ExportService.exportData(dataMap!, value, fileName, context);
            return;
          }

          // Build a data map by trying to extract ChatAnalysis from context
          // If callers want to export a widget image, they can keep using
          // ExportService.exportAndShareWidget. This menu focuses on data export.
          // Here we attempt to locate a ChatAnalysis instance placed in the
          // widget tree via an InheritedWidget or supplied via the parent.
          // For now callers should call ExportService.exportData directly if
          // they have the ChatAnalysis map.
          // As a convenience, if a RepaintBoundary key is provided we will
          // try to export the widget image when 'image' is selected (not used)

          // The UI should call ExportService.exportData with a proper map.
          // To keep this component useful, we'll look for a `Map<String,dynamic>`
          // attached to the button via a simple mechanism: the parent can set
          // `ExportDataProvider` (not implemented here). For now, show a message
          // to the user explaining how to wire data exports.

          final loc = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.export_no_data_provided)),
          );
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: 'csv', child: Text(loc.export_csv)),
          PopupMenuItem(value: 'json', child: Text(loc.export_json)),
          PopupMenuItem(value: 'yaml', child: Text(loc.export_yaml)),
          PopupMenuItem(value: 'toon', child: Text(loc.export_toon)),
          PopupMenuItem(value: 'image', child: Text(loc.export_image)),
        ],
      ),
    );
  }
}
