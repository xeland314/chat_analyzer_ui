import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../src/settings/display_settings.dart';

class DisplayOptionsDialog extends StatefulWidget {
  final double initialDisplayCount;
  final Set<String> initialIgnoredWords;
  final Function(double) onDisplayCountChanged;
  final Function(Set<String>) onIgnoredWordsChanged;

  const DisplayOptionsDialog({
    super.key,
    required this.initialDisplayCount,
    required this.initialIgnoredWords,
    required this.onDisplayCountChanged,
    required this.onIgnoredWordsChanged,
  });

  @override
  State<DisplayOptionsDialog> createState() => _DisplayOptionsDialogState();
}

class _DisplayOptionsDialogState extends State<DisplayOptionsDialog> {
  late double _displayCount;
  late Set<String> _ignoredWords;
  final _textController = TextEditingController();
  late Locale _selectedLocale;

  @override
  void initState() {
    super.initState();
    _displayCount = widget.initialDisplayCount;
    _ignoredWords = Set.from(widget.initialIgnoredWords);
    _loadPersistentSettings();
  }

  bool _loadingSettings = false;

  Future<void> _loadPersistentSettings() async {
    if (!mounted) return;
    setState(() {
      _loadingSettings = true;
    });
    final settings = await DisplaySettings.load();
    if (!mounted) return;
    setState(() {
      _displayCount = settings.displayCount;
      _ignoredWords = Set.from(settings.ignoredWords);
      _loadingSettings = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLocale = Localizations.localeOf(context);
  }

  void _addIgnoredWord() {
    final word = _textController.text.trim().toLowerCase();
    if (word.isNotEmpty) {
      setState(() {
        _ignoredWords.add(word);
      });
      _textController.clear();
    }
  }

  void _removeIgnoredWord(String word) {
    setState(() {
      _ignoredWords.remove(word);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(appLocalizations.display_options_dialog_title),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            if (_loadingSettings)
              const Center(child: CircularProgressIndicator())
            else ...[
              Text(
                appLocalizations
                    .display_options_dialog_number_of_words_to_display,
              ),
            Slider(
              value: _displayCount,
              min: 1,
              max: 20,
              divisions: 19,
              label: _displayCount.round().toString(),
              onChanged: (value) {
                setState(() {
                  _displayCount = value;
                });
              },
            ),
            ],
            const SizedBox(height: 20),
            Text(appLocalizations.display_options_dialog_ignored_words),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: appLocalizations
                    .display_options_dialog_add_a_word_to_ignore,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addIgnoredWord,
                ),
              ),
              onSubmitted: (_) => _addIgnoredWord(),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: _ignoredWords
                  .map(
                    (word) => Chip(
                      label: Text(word),
                      onDeleted: () => _removeIgnoredWord(word),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            Text(
              appLocalizations.display_options_dialog_language_selector_title,
            ),
            DropdownButton<Locale>(
              value: _selectedLocale,
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  setState(() {
                    _selectedLocale = newLocale;
                  });
                  ChatAnalyzerApp.of(context)!.setLocale(newLocale);
                }
              },
              items: AppLocalizations.supportedLocales.map((Locale locale) {
                return DropdownMenuItem<Locale>(
                  value: locale,
                  child: Text(
                    locale.languageCode == 'en'
                        ? appLocalizations.language_english
                        : appLocalizations.language_spanish,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.display_options_dialog_cancel_button),
        ),
        TextButton(
          onPressed: () async {
            // Persist settings
            final settings = await DisplaySettings.load();
            await settings.setDisplayCount(_displayCount);
            await settings.setIgnoredWords(_ignoredWords.toList());

            if (!mounted) return;
            widget.onDisplayCountChanged(_displayCount);
            widget.onIgnoredWordsChanged(_ignoredWords);
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.display_options_dialog_save_button),
        ),
      ],
    );
  }
}
