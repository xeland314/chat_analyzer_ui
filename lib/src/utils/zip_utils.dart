import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';

class ZipInvalidException implements Exception {
  final String message;
  ZipInvalidException(this.message);
  @override
  String toString() => 'ZipInvalidException: $message';
}

/// Extracts the first .txt file contents from a ZIP file.
/// Throws [ZipInvalidException] if more than 10 nested zip files are found
/// or if no .txt file is present.
Future<String> extractFirstTxtFromZip(File zipFile) async {
  final bytes = await zipFile.readAsBytes();
  final archive = ZipDecoder().decodeBytes(bytes);

  int innerZipCount = 0;
  ArchiveFile? txtEntry;

  for (final entry in archive) {
    final name = entry.name.toLowerCase();
    if (name.endsWith('.zip')) {
      innerZipCount++;
      if (innerZipCount > 10) {
        throw ZipInvalidException('ZIP inválido: contiene más de 10 archivos .zip internos');
      }
    }
    if (txtEntry == null && name.endsWith('.txt')) {
      txtEntry = entry;
    }
  }

  if (txtEntry == null) {
    throw ZipInvalidException('ZIP inválido: no contiene archivos .txt');
  }

  final contentBytes = txtEntry.content as List<int>;
  try {
    return utf8.decode(contentBytes);
  } catch (e) {
    // fallback to latin1 if utf8 fails
    return latin1.decode(contentBytes);
  }
}
