import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../exports/export_service.dart';

class InfoWidgetWrapper extends StatelessWidget {
  final Widget child;
  final String title;
  final String infoContent;
  final GlobalKey exportKey; // Clave para el RepaintBoundary
  final String fileNameBase; // Nombre base del archivo

  const InfoWidgetWrapper({
    super.key,
    required this.child,
    required this.title,
    required this.infoContent,
    required this.exportKey,
    required this.fileNameBase,
  });

  // Lógica del diálogo de información (sin cambios)
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ℹ️ $title'),
          content: SingleChildScrollView(child: Text(infoContent)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Nuevo método para manejar la exportación
  void _handleExport(BuildContext context) {
    // Generar el nombre de archivo único aquí
    final uniqueFileName = '${fileNameBase}_${Uuid().v4()}';

    // Llamar al servicio estático directamente
    ExportService.exportAndShareWidget(
      exportKey,
      'C.A. xeland314',
      uniqueFileName,
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Envolvemos el child con RepaintBoundary para permitir la captura de pantalla
        RepaintBoundary(
          key: exportKey, // Asignamos la clave global
          child: child,
        ),
        const SizedBox(height: 8),
        // 2. Botones de acción (Exportar e Información)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Botón de Exportar
              TextButton.icon(
                onPressed: () => _handleExport(context),
                icon: const Icon(Icons.share, size: 18),
                label: const Text(
                  'Exportar Gráfico',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              // Botón de Información
              TextButton.icon(
                icon: const Icon(Icons.info_outline, size: 18),
                label: const Text(
                  'Información',
                  style: TextStyle(fontSize: 12),
                ),
                onPressed: () => _showInfoDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
