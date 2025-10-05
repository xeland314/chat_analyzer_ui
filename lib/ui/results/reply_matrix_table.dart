import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../chat/chat_avatar.dart';

/// Tabla que muestra quién le responde a quién.
class ReplyMatrixTable extends StatefulWidget {
  final Map<String, Map<String, int>> replies;

  const ReplyMatrixTable({super.key, required this.replies});

  @override
  State<ReplyMatrixTable> createState() => _ReplyMatrixTableState();
}

class _ReplyMatrixTableState extends State<ReplyMatrixTable> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Método para copiar la matriz completa de datos al portapapeles
  void _copyMatrixToClipboard() {
    final participants = widget.replies.keys.toList()..sort();
    final buffer = StringBuffer();
    final outDegree = <String, int>{};
    final inDegree = <String, int>{};
    final balance = <String, int>{};

    // Recalcular grados y balance (similar a la lógica en build)
    for (final p1 in participants) {
      outDegree[p1] = 0;
      inDegree[p1] = 0;
    }
    for (final replier in participants) {
      for (final repliee in participants) {
        final count = widget.replies[replier]?[repliee] ?? 0;
        outDegree[replier] = (outDegree[replier] ?? 0) + count;
        inDegree[repliee] = (inDegree[repliee] ?? 0) + count;
      }
    }
    for (final p in participants) {
      balance[p] = (outDegree[p] ?? 0) - (inDegree[p] ?? 0);
    }

    // --- 2. Construir el Encabezado de la Matriz ---
    buffer.write('Replier \\ To\t');
    buffer.write(participants.join('\t'));
    buffer.write('\tOut-degree (Replies Sent)\t');
    buffer.writeln('Balance (Out - In)');

    // --- 3. Construir las Filas de Datos (Replier data) ---
    for (final replier in participants) {
      buffer.write('$replier\t'); // Participante (replier)

      // Celdas de conteo (repliee data)
      for (final repliee in participants) {
        final count = widget.replies[replier]?[repliee] ?? 0;
        buffer.write('$count\t');
      }

      // Datos de grados y balance
      buffer.write('${outDegree[replier]}\t');
      buffer.writeln('${balance[replier]}');
    }

    // --- 4. Construir la Fila Final (In-degree) ---
    buffer.write('In-degree (Replies Received)\t');
    for (final p in participants) {
      buffer.write('${inDegree[p]}\t');
    }
    buffer.writeln('\t'); // Campos vacíos finales

    // 5. Copiar al portapapeles y notificar
    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tabla de respuestas copiada al portapapeles (formato TSV)',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final participants = widget.replies.keys.toList()..sort();
    if (participants.isEmpty) return const SizedBox.shrink();

    // Calculate degrees
    final outDegree = <String, int>{};
    final inDegree = <String, int>{};
    for (final p1 in participants) {
      outDegree[p1] = 0;
      inDegree[p1] = 0;
    }

    for (final replier in participants) {
      for (final repliee in participants) {
        final count = widget.replies[replier]?[repliee] ?? 0;
        outDegree[replier] = (outDegree[replier] ?? 0) + count;
        inDegree[repliee] = (inDegree[repliee] ?? 0) + count;
      }
    }

    final balance = <String, int>{};
    for (final p in participants) {
      balance[p] = (outDegree[p] ?? 0) - (inDegree[p] ?? 0);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who Replies to Whom',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        // La tabla
        Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                const DataColumn(label: Text('Replier \\ To')),
                ...participants.map((p) => DataColumn(label: authorAvatar(p))),
                const DataColumn(label: Text('Out-degree (Replies Sent)')),
                const DataColumn(label: Text('Balance (Out - In)')),
              ],
              rows: [
                ...participants.map((replier) {
                  return DataRow(
                    cells: [
                      DataCell(authorAvatar(replier)),
                      ...participants.map((repliee) {
                        final count = widget.replies[replier]?[repliee] ?? 0;
                        return DataCell(Text(count.toString()));
                      }),
                      DataCell(Text(outDegree[replier].toString())),
                      DataCell(Text(balance[replier].toString())),
                    ],
                  );
                }),
                DataRow(
                  cells: [
                    const DataCell(Text('In-degree (Replies Received)')),
                    ...participants.map((p) {
                      return DataCell(Text(inDegree[p].toString()));
                    }),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // El nuevo botón de copiar
        Align(
          alignment: Alignment.center,
          child: ElevatedButton.icon(
            onPressed: _copyMatrixToClipboard,
            icon: const Icon(Icons.copy),
            label: const Text('Copiar Tabla de Respuestas'),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
