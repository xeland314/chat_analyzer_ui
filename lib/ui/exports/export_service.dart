import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class ExportService {
  static Future<void> exportAndShareWidget(
    GlobalKey repaintBoundaryKey,
    String watermarkText,
    String fileName,
    BuildContext context,
  ) async {
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
            color: Colors.black.withOpacity(0.5),
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

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image saved to: $filePath'),
              action:
                  (Platform.isLinux || Platform.isWindows || Platform.isMacOS)
                  ? SnackBarAction(
                      label: 'Open Folder',
                      onPressed: () {
                        if (outputDirectory != null) {
                          launchUrl(
                            Uri.parse(
                              'file://${outputDirectory.path.toString()}',
                            ),
                          );
                        }
                      },
                    )
                  : null,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not find a suitable directory to save the image.',
              ),
            ),
          );
        }
      } else {
        // For mobile, use share_plus
        final directory = (await getTemporaryDirectory()).path;
        final filePath = '${directory}/$fileName.png';
        final File file = File(filePath);
        await file.writeAsBytes(watermarkedPngBytes);

        await Share.shareXFiles([
          XFile(filePath),
        ], text: 'Check out my chat analysis!');
      }
    } catch (e) {
      debugPrint('Error exporting widget: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error exporting image: $e')));
    }
  }
}
