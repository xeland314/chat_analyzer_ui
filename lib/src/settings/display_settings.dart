import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Versioned display settings stored in SharedPreferences.
///
/// Key format:
/// - `display.settings_v1` : JSON-encoded settings blob
/// - `display.settings_version` : integer version number
class DisplaySettings extends ChangeNotifier {
  static const _prefsKey = 'display.settings_v1';
  static const _versionKey = 'display.settings_version';
  static const _currentVersion = 1;

  bool showTimestamps;
  String timeFormat; // 'relative' | 'absolute' | '12h' | '24h'
  String theme; // 'system' | 'light' | 'dark'
  bool compactMode;
  double fontScale; // 0.75 .. 1.5
  String hourReference; // 'UTC' or 'local'
  double displayCount; // number of words/items to display
  List<String> ignoredWords;

  DisplaySettings({
    this.showTimestamps = true,
    this.timeFormat = 'relative',
    this.theme = 'system',
    this.compactMode = false,
    this.fontScale = 1.0,
    this.hourReference = 'UTC',
    this.displayCount = 10.0,
    List<String>? ignoredWords,
  }) : ignoredWords = ignoredWords ?? [];

  Map<String, dynamic> toMap() => {
        'showTimestamps': showTimestamps,
        'timeFormat': timeFormat,
        'theme': theme,
        'compactMode': compactMode,
      'fontScale': fontScale,
      'hourReference': hourReference,
      'displayCount': displayCount,
      'ignoredWords': ignoredWords,
      };

  factory DisplaySettings.fromMap(Map<String, dynamic> m) => DisplaySettings(
        showTimestamps: m['showTimestamps'] ?? true,
        timeFormat: m['timeFormat'] ?? 'relative',
        theme: m['theme'] ?? 'system',
        compactMode: m['compactMode'] ?? false,
        fontScale: (m['fontScale'] is num) ? (m['fontScale'] as num).toDouble() : 1.0,
        hourReference: m['hourReference'] ?? 'UTC',
        displayCount: (m['displayCount'] is num) ? (m['displayCount'] as num).toDouble() : 10.0,
        ignoredWords: (m['ignoredWords'] is List) ? List<String>.from(m['ignoredWords']) : null,
      );

  /// Load settings from SharedPreferences. If none exist, returns defaults.
  static Future<DisplaySettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final version = prefs.getInt(_versionKey) ?? 0;
    final raw = prefs.getString(_prefsKey);

    if (raw == null) {
      // No stored settings; return defaults and persist version
      final defaults = DisplaySettings();
      await prefs.setInt(_versionKey, _currentVersion);
      return defaults;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      // Migration hook: if stored version < current, migrate here.
      if (version < _currentVersion) {
        final migrated = await _migrate(decoded, version);
        await prefs.setString(_prefsKey, jsonEncode(migrated));
        await prefs.setInt(_versionKey, _currentVersion);
        return DisplaySettings.fromMap(migrated);
      }
      return DisplaySettings.fromMap(decoded);
    } catch (e) {
      // Corrupt data: reset to defaults
      final defaults = DisplaySettings();
      await prefs.setString(_prefsKey, jsonEncode(defaults.toMap()));
      await prefs.setInt(_versionKey, _currentVersion);
      return defaults;
    }
  }

  static Future<Map<String, dynamic>> _migrate(Map<String, dynamic> old, int oldVersion) async {
    // Placeholder migration logic. If schema changes in future versions,
    // implement migration steps here based on oldVersion.
    // Currently no changes, so just return old cast to Map<String,dynamic>.
    return Map<String, dynamic>.from(old);
  }

  /// Persist current settings to SharedPreferences.
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(toMap()));
    await prefs.setInt(_versionKey, _currentVersion);
  }

  /// Reset settings to defaults and persist.
  Future<void> reset() async {
    final defaults = DisplaySettings();
    showTimestamps = defaults.showTimestamps;
    timeFormat = defaults.timeFormat;
    theme = defaults.theme;
    compactMode = defaults.compactMode;
    fontScale = defaults.fontScale;
    hourReference = defaults.hourReference;
    displayCount = defaults.displayCount;
    ignoredWords = defaults.ignoredWords;
    await save();
    notifyListeners();
  }

  // Setters that persist automatically
  Future<void> setShowTimestamps(bool v) async {
    showTimestamps = v;
    await save();
    notifyListeners();
  }

  Future<void> setTimeFormat(String v) async {
    timeFormat = v;
    await save();
    notifyListeners();
  }

  Future<void> setTheme(String v) async {
    theme = v;
    await save();
    notifyListeners();
  }

  Future<void> setCompactMode(bool v) async {
    compactMode = v;
    await save();
    notifyListeners();
  }

  Future<void> setFontScale(double v) async {
    fontScale = v.clamp(0.5, 2.0);
    await save();
    notifyListeners();
  }

  Future<void> setHourReference(String v) async {
    hourReference = v;
    await save();
    notifyListeners();
  }

  Future<void> setDisplayCount(double v) async {
    displayCount = v;
    await save();
    notifyListeners();
  }

  Future<void> setIgnoredWords(List<String> words) async {
    ignoredWords = List<String>.from(words);
    await save();
    notifyListeners();
  }
}
