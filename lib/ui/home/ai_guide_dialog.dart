import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../src/models/chat_analysis.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/exports/export_service.dart';

class AiGuideDialog extends StatefulWidget {
  final ChatAnalysis analysis;

  const AiGuideDialog({super.key, required this.analysis});

  @override
  State<AiGuideDialog> createState() => _AiGuideDialogState();
}

class _AiGuideDialogState extends State<AiGuideDialog> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildCompactSummary() {
    final participants = widget.analysis.participants.map((p) {
      return {
        'name': p.name,
        'messageCount': p.messageCount,
        'multimediaCount': p.multimediaCount,
        'peak_hour': p.messageCountByHour.entries.isEmpty
            ? 0
            : p.messageCountByHour.entries.reduce((a, b) => a.value >= b.value ? a : b).key,
        'messages_by_hour': List<int>.generate(24, (i) => (p.messageCountByHour[i] ?? 0).toInt()),
        'top_words': p.getMostCommonWords(10).map((e) => [e.key, e.value]).toList(),
        'top_emojis': p.getMostCommonEmojis(5).map((e) => [e.key, e.value]).toList(),
      };
    }).toList();

    final totalMessages = widget.analysis.allMessagesChronological.length;

    final globalWordFreq = <String, int>{};
    for (final p in widget.analysis.participants) {
      p.wordFrequency.forEach((k, v) => globalWordFreq[k] = (globalWordFreq[k] ?? 0) + (v).toInt());
    }
    final topWords = globalWordFreq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topWordsList = topWords.take(10).map((e) => [e.key, e.value]).toList();

    final globalEmojiFreq = <String, int>{};
    for (final p in widget.analysis.participants) {
      p.emojiFrequency.forEach((k, v) => globalEmojiFreq[k] = (globalEmojiFreq[k] ?? 0) + (v).toInt());
    }
    final topEmojis = globalEmojiFreq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topEmojisList = topEmojis.take(10).map((e) => [e.key, e.value]).toList();

    final sentimentAgg = <String, int>{'positive': 0, 'negative': 0, 'neutral': 0};
    for (final p in widget.analysis.participants) {
      final s = p.sentimentAnalysis;
      sentimentAgg['positive'] = sentimentAgg['positive']! + ((s['Positive'] ?? 0) as num).toInt();
      sentimentAgg['negative'] = sentimentAgg['negative']! + ((s['Negative'] ?? 0) as num).toInt();
      sentimentAgg['neutral'] = sentimentAgg['neutral']! + ((s['Neutral'] ?? 0) as num).toInt();
    }

    return {
      'total_messages': totalMessages,
      'participants': participants,
      'summary': {
        'top_words': topWordsList,
        'top_emojis': topEmojisList,
        'sentiment': sentimentAgg,
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final compact = _buildCompactSummary();
    // Constrain height so content can scroll on small screens
    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    // Example prompts (can be localized later)
    final prompts = <Map<String, String>>[
      {
        'title': 'Executive Summary (short)',
        'text': 'Provide a 3–4 sentence executive summary of this conversation, highlighting main topics, participants activity, and suggested actions. Use the compact JSON payload provided.'
      },
      {
        'title': 'Topic Extraction',
        'text': 'Extract the top 5 topics discussed in the conversation and list supporting example messages or keywords.'
      },
      {
        'title': 'Action Items',
        'text': 'Identify up to 10 concrete action items mentioned or implied in the conversation, with an estimated priority (high/medium/low).'
      },
    ];

    // Attach suggested prompts into the compact payload for TOON export
    final suggestedPrompts = prompts.map((p) => {'title': p['title'], 'text': p['text']}).toList();
    final compactForToon = Map<String, dynamic>.from(compact);
    compactForToon['suggested_prompts'] = suggestedPrompts;

    final compactJson = const JsonEncoder.withIndent('  ').convert(compact);

    return AlertDialog(
      title: Text('${loc.export_button_label} — AI Guide'),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.analysis_result_view_advanced_analysis_title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Total messages: ${compact['total_messages']}'),
                const SizedBox(height: 8),
                Text('Participants:', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                ...widget.analysis.participants.map((p) => ListTile(
                      dense: true,
                      title: Text(p.name),
                      subtitle: Text('Messages: ${p.messageCount}  •  Peak hour: ${p.messageCountByHour.entries.isEmpty ? 0 : p.messageCountByHour.entries.reduce((a,b) => a.value>=b.value ? a : b).key}'),
                    )),
                const SizedBox(height: 8),
                Text('Top words', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(compact['summary']['top_words'].map((e) => '${e[0]} (${e[1]})').join(', ')),
                const SizedBox(height: 8),
                Text('Top emojis', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(compact['summary']['top_emojis'].map((e) => '${e[0]} (${e[1]})').join(', ')),
                const SizedBox(height: 12),
                Text('Sample prompts', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                ...prompts.map((p) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['title']!, style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: SelectableText(p['text']!)),
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: 'Copy prompt',
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: p['text']!));
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prompt copied')));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 8),
                Text('Compact JSON (copy to send to an LLM):', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                SelectableText(compactJson),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Create a TOON representation of the compact summary and copy it to clipboard
                        try {
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
                          final toonText = await ExportService.toToonString(compactForToon);
                          await Clipboard.setData(ClipboardData(text: toonText));
                          if (!mounted) return;
                          navigator.pop();
                          messenger.showSnackBar(const SnackBar(content: Text('TOON copied to clipboard')));
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copy failed: $e')));
                        }
                      },
                      icon: const Icon(Icons.copy_all),
                      label: const Text('Copy as TOON'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: compactJson));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compact JSON copied to clipboard')));
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy JSON'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.disclaimer_modal_privacy_notice_close_button),
        ),
      ],
    );
  }
}
