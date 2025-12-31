import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'ui/pages/home_page.dart';
import 'ui/common/log.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const ChatAnalyzerApp());
}

class ChatAnalyzerApp extends StatefulWidget {
  const ChatAnalyzerApp({super.key});

  @override
  State<ChatAnalyzerApp> createState() => _ChatAnalyzerAppState();

  static _ChatAnalyzerAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_ChatAnalyzerAppState>();
}

class _ChatAnalyzerAppState extends State<ChatAnalyzerApp> {
  late StreamSubscription _intentSub;
  String? _sharedText;
  Locale? _locale;

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  Future<File> _persistSharedFile(File tempFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    String baseName = tempFile.uri.pathSegments.last;
    String newPath = '${appDir.path}/$baseName';
    File newFile = File(newPath);

    int counter = 1;
    while (await newFile.exists()) {
      // Si ya existe, agregamos un sufijo
      final nameWithoutExt = baseName.contains('.')
          ? baseName.substring(0, baseName.lastIndexOf('.'))
          : baseName;
      final ext = baseName.contains('.')
          ? baseName.substring(baseName.lastIndexOf('.'))
          : '';
      newPath = '${appDir.path}/$nameWithoutExt($counter)$ext';
      newFile = File(newPath);
      counter++;
    }

    return await tempFile.copy(newFile.path);
  }

  Future<void> _readAndSetSharedText(String pathOrUri) async {
    Log.add('📂 _readAndSetSharedText: $pathOrUri');
    try {
      final file = File(pathOrUri);
      final fileExists = await file.exists();
      Log.add('🤔 File exists: $fileExists');
      if (fileExists) {
        // Copiamos a Documents
        final persistedFile = await _persistSharedFile(file);
        Log.add('✅ Copied file to: ${persistedFile.path}');

        final content = await persistedFile.readAsString();
        Log.add('📄 Content length: ${content.length}');

        if (!mounted) return;
        setState(() => _sharedText = content);
        return;
      }

      // fallback si no existe
      Log.add('🤷 File does not exist, falling back to pathOrUri');
      setState(() => _sharedText = pathOrUri);
    } catch (e) {
      Log.add('❌ _readAndSetSharedText error: $e');
      setState(() => _sharedText = pathOrUri);
    }
  }

  @override
  void initState() {
    super.initState();
    Log.add('🚀 App initState');

    _locale =
        PlatformDispatcher.instance.locale; // Initialize with system locale

    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (files) async {
        Log.add(
          '📡 MediaStream received: ${files.map((f) => f.toMap()).toList()}',
        );
        if (files.isNotEmpty) {
          final path = files.first.path;
          Log.add('➡️ MediaStream first path: $path');
          await _readAndSetSharedText(path);
        }
      },
      onError: (err) {
        Log.add('❌ getMediaStream error: $err');
      },
    );

    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((files) async {
          Log.add(
            '📡 InitialMedia received: ${files.map((f) => f.toMap()).toList()}',
          );
          if (files.isNotEmpty) {
            final path = files.first.path;
            Log.add('➡️ InitialMedia first path: $path');
            await _readAndSetSharedText(path);
            //Log.add('♻️ Resetting ReceiveSharingIntent');
            //ReceiveSharingIntent.instance.reset();
          }
        })
        .catchError((e) {
          Log.add('❌ getInitialMedia error: $e');
        });
  }

  @override
  void dispose() {
    Log.add('🛑 Disposing App, cancelling intent subscription');
    _intentSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Analyzer',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale, // Use the _locale variable
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomePage(initialText: _sharedText ?? ''),
    );
  }
}
