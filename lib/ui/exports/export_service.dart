import 'dart:io';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:json2yaml/json2yaml.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:toon_format/toon_format.dart' as toon;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../common/log.dart';

class ExportService {
  static Future<void> exportAndShareWidget(
    GlobalKey repaintBoundaryKey,
    String watermarkText,
    String fileName,
    BuildContext context,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final RenderRepaintBoundary boundary =
          repaintBoundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Add watermark
      final ui.Codec codec = await ui.instantiateImageCodec(pngBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image originalImage = frameInfo.image;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      canvas.drawImage(originalImage, Offset.zero, Paint());

      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: watermarkText,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.5),
            fontSize:
                originalImage.width *
                0.03, // Adjust font size based on image width
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: originalImage.width.toDouble());

      // Position watermark at bottom right
      textPainter.paint(
        canvas,
        Offset(
          originalImage.width -
              textPainter.width -
              (originalImage.width * 0.02),
          originalImage.height -
              textPainter.height -
              (originalImage.height * 0.02),
        ),
      );

      final img = await recorder.endRecording().toImage(
        originalImage.width,
        originalImage.height,
      );
      final ByteData? watermarkedByteData = await img.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List watermarkedPngBytes = watermarkedByteData!.buffer
          .asUint8List();

      if (kIsWeb ||
          Platform.isLinux ||
          Platform.isWindows ||
          Platform.isMacOS) {
        // For desktop and web, save to a user-friendly directory
        Directory? outputDirectory;
        if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
          outputDirectory = await getDownloadsDirectory();
        } else if (kIsWeb) {
          // For web, a direct download is usually triggered by the browser
          // This part might need a different approach for web downloads
          // For now, we'll just save to temp and let the browser handle it if possible
          outputDirectory = await getTemporaryDirectory();
        }

        if (outputDirectory != null) {
          final filePath = '${outputDirectory.path}/$fileName.png';
          final File file = File(filePath);
          await file.writeAsBytes(watermarkedPngBytes);

          messenger.showSnackBar(
            SnackBar(
              content: Text(loc.export_saved_image(filePath)),
              action:
                  (Platform.isLinux || Platform.isWindows || Platform.isMacOS)
                  ? SnackBarAction(
                      label: loc.open_folder_action,
                      onPressed: () {
                        if (outputDirectory != null) {
                          launchUrl(
                            Uri.file(outputDirectory.path),
                          );
                        }
                      },
                    )
                  : null,
            ),
          );
        } else {
          messenger.showSnackBar(
            SnackBar(content: Text(loc.export_error_no_directory)),
          );
        }
      } else {
        // For mobile, use share_plus
        final directory = (await getTemporaryDirectory()).path;
        final filePath = '$directory/$fileName.png';
        final File file = File(filePath);
        await file.writeAsBytes(watermarkedPngBytes);

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(filePath)],
            text: loc.share_message_analysis,
          ),
        );
      }
    } catch (e) {
      Log.add('Error exporting widget: $e');
      messenger.showSnackBar(
        SnackBar(content: Text(loc.export_error_exporting(e.toString()))),
      );
    }
  }

  /// Export structured data (ChatAnalysis) to the requested format and
  /// save/share it. Supported formats: csv, json, yaml, toon
  static Future<void> exportData(
    Map<String, dynamic> data,
    String format,
    String fileNameWithoutExt,
    BuildContext context,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final formatLower = format.toLowerCase();
      String content;
      String ext = formatLower;

      if (formatLower == 'json') {
        content = const JsonEncoder.withIndent('  ').convert(data);
        ext = 'json';
      } else if (formatLower == 'yaml') {
        // json2yaml converts a decoded JSON structure to YAML
        content = json2yaml(data);
        ext = 'yaml';
      } else if (formatLower == 'csv') {
        // For CSV we export the messages list (if present)
        final messages = data['allMessagesChronological'] as List<dynamic>?;
        if (messages == null) {
          content = '';
        } else {
          final buffer = StringBuffer();
          buffer.writeln('author,dateTime,content,sentimentScore');
          for (final m in messages) {
            final author = (m['author'] ?? '').toString().replaceAll('"', '""');
            final date = (m['dateTime'] ?? '').toString();
            final contentField = (m['content'] ?? '').toString().replaceAll(
              '"',
              '""',
            );
            final sentiment = (m['sentimentScore'] ?? '').toString();
            // Wrap content in quotes to preserve commas/newlines
            buffer.writeln('"$author","$date","$contentField",$sentiment');
          }
          content = buffer.toString();
          ext = 'csv';
        }
      } else if (formatLower == 'toon') {
        // Use the official toon-dart encoder if available. Fall back to YAML
        // serialization wrapped in a minimal TOON header if encoding fails.
        try {
          content = toon.encode(data);
          ext = 'toon';
        } catch (e) {
          final yamlBody = json2yaml(data);
          content = 'TOON v1\n---\n$yamlBody';
          ext = 'toon';
        }
      } else {
        content = const JsonEncoder.withIndent('  ').convert(data);
        ext = 'json';
      }

      final bytes = utf8.encode(content);

      // Save to Downloads on desktop, or temp + share on mobile
      if (kIsWeb ||
          Platform.isLinux ||
          Platform.isWindows ||
          Platform.isMacOS) {
        final outputDirectory = await getDownloadsDirectory();
        final dir = outputDirectory ?? await getTemporaryDirectory();
        final path = '${dir.path}/$fileNameWithoutExt.$ext';
        final file = File(path);
        await file.writeAsBytes(bytes);

        messenger.showSnackBar(
          SnackBar(content: Text(loc.export_exported_to(path))),
        );
      } else {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/$fileNameWithoutExt.$ext';
        final file = File(path);
        await file.writeAsBytes(bytes);

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(path)],
            text: loc.share_exported_text('$fileNameWithoutExt.$ext'),
          ),
        );
      }
    } catch (e) {
      Log.add('Error exporting data: $e');
      messenger.showSnackBar(
        SnackBar(content: Text(loc.export_error_exporting(e.toString()))),
      );
    }
  }

  /// Encode a data map to a TOON string. Returns the encoded TOON text.
  /// Falls back to a minimal TOON wrapper around YAML if the encoder isn't available.
  static Future<String> toToonString(Map<String, dynamic> data) async {
    try {
      // Use the toon encoder if available
      return toon.encode(data);
    } catch (e) {
      // Fallback: wrap YAML body with a simple TOON header
      final yamlBody = json2yaml(data);
      return 'TOON v1\n---\n$yamlBody';
    }
  }

  /// Export a square transition matrix (Map<from, Map<to, value>>) to TSV or CSV.
  /// Saves to Downloads on desktop or shares on mobile. Uses localization for messages.
  static Future<void> exportMatrix(
    Map<String, Map<String, double>> matrix,
    String fileNameWithoutExt,
    BuildContext context, {
    String delimiter = '\t',
  }) async {
    final loc = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final participants = matrix.keys.toList()..sort();

      final buffer = StringBuffer();
      // Header
      buffer.write('${loc.markov_chain_view_from_to}$delimiter');
      buffer.writeln(participants.join(delimiter));

      for (final p1 in participants) {
        buffer.write('$p1$delimiter');
        for (final p2 in participants) {
          final val = matrix[p1]?[p2] ?? 0.0;
          buffer.write(val.toStringAsFixed(3));
          buffer.write(delimiter);
        }
        buffer.writeln();
      }

      final content = buffer.toString();
      final bytes = utf8.encode(content);

      final ext = delimiter == '\t' ? 'tsv' : 'csv';

      if (kIsWeb ||
          Platform.isLinux ||
          Platform.isWindows ||
          Platform.isMacOS) {
        final outputDirectory = await getDownloadsDirectory();
        final dir = outputDirectory ?? await getTemporaryDirectory();
        final path = '${dir.path}/$fileNameWithoutExt.$ext';
        final file = File(path);
        await file.writeAsBytes(bytes);
        messenger.showSnackBar(
          SnackBar(content: Text(loc.export_exported_to(path))),
        );
      } else {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/$fileNameWithoutExt.$ext';
        final file = File(path);
        await file.writeAsBytes(bytes);
        await SharePlus.instance.share(
          ShareParams(
            text: loc.share_exported_text('$fileNameWithoutExt.$ext'),

            files: [XFile(path)],
          ),
        );
      }
    } catch (e) {
      Log.add('Error exporting matrix: $e');
      messenger.showSnackBar(
        SnackBar(content: Text(loc.export_error_exporting(e.toString()))),
      );
    }
  }
}
