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

    return PopupMenuButton<String>(
      tooltip: loc.export_button_label,
      onSelected: (value) async {
        // If the user selected image, export the widget image using the
        // provided RepaintBoundary key.
        if (value == 'image') {
          try {
            await ExportService.exportAndShareWidget(
              repaintBoundaryKey,
              loc.name, // use app name as watermark text
              fileName,
              context,
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loc.export_error_exporting(e.toString()))),
            );
          }
          return;
        }

        // For data formats, require a provided data map.
        if (dataMap != null) {
          await ExportService.exportData(dataMap!, value, fileName, context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.export_no_data_provided)),
          );
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'csv', child: Text(loc.export_csv)),
        PopupMenuItem(value: 'json', child: Text(loc.export_json)),
        PopupMenuItem(value: 'yaml', child: Text(loc.export_yaml)),
        PopupMenuItem(value: 'toon', child: Text(loc.export_toon)),
        PopupMenuItem(value: 'image', child: Text(loc.export_image)),
      ],
      child: FloatingActionButton(
        onPressed: null,
        tooltip: loc.export_button_label,
        child: const Icon(Icons.share),
      ),
    );
  }
}
