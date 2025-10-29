import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../src/analysis/matrix_operations.dart';
import '../chat/chat_avatar.dart';
import '../../l10n/app_localizations.dart';

class MarkovChainView extends StatefulWidget {
  final Map<String, Map<String, int>> replies;

  const MarkovChainView({super.key, required this.replies});

  @override
  State<MarkovChainView> createState() => _MarkovChainViewState();
}

class _MarkovChainViewState extends State<MarkovChainView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _copyMatrixToClipboard() {
    final appLocalizations = AppLocalizations.of(context)!;
    final transitionMatrix = normalizeMatrix(widget.replies);
    final participants = transitionMatrix.keys.toList()..sort();

    final buffer = StringBuffer();

    buffer.write('${appLocalizations.markov_chain_view_from_to}\t');
    buffer.writeln(participants.join('\t'));

    // Escribir filas de datos
    for (final p1 in participants) {
      buffer.write('$p1\t'); // Nombre del participante de la fila
      for (final p2 in participants) {
        final prob = transitionMatrix[p1]?[p2] ?? 0;
        // Formatear a 3 decimales y usar tabulador
        buffer.write('${prob.toStringAsFixed(3)}\t');
      }
      buffer.writeln();
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appLocalizations.markov_chain_view_matrix_copied_snackbar),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final transitionMatrix = normalizeMatrix(widget.replies);
    final participants = transitionMatrix.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          appLocalizations.markov_chain_view_title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        // Tabla de datos con scroll horizontal y scrollbar
        Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: DataTable(
              columns: [
                DataColumn(label: Text(appLocalizations.markov_chain_view_from_to)),
                ...participants.map((p) => DataColumn(label: authorAvatar(p))),
              ],
              rows: participants.map((p1) {
                return DataRow(
                  cells: [
                    DataCell(authorAvatar(p1)),
                    ...participants.map((p2) {
                      final prob = transitionMatrix[p1]?[p2] ?? 0;
                      return DataCell(Text(prob.toStringAsFixed(3)));
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton.icon(
            onPressed: _copyMatrixToClipboard,
            icon: const Icon(Icons.copy),
            label: Text(appLocalizations.markov_chain_view_copy_matrix_button),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
