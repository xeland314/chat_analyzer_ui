import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';
import '../../src/models/chat_analysis.dart';
import '../../src/models/chat_message.dart';
import '../../src/models/chat_participant.dart';
import 'chat_parser.dart'; // Importar el parser antiguo de Dart

// ============================================================================
// FFI Bindings para Rust
// ============================================================================

typedef ParseWhatsAppChatNative =
    ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> content);
typedef ParseWhatsAppChatDart =
    ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> content);

typedef FreeStringNative = ffi.Void Function(ffi.Pointer<Utf8> ptr);
typedef FreeStringDart = void Function(ffi.Pointer<Utf8> ptr);

// Estructuras JSON de respuesta
class ParsedMessage {
  final String author;
  final String content;
  final int timestamp;
  final double sentimentScore;

  ParsedMessage({
    required this.author,
    required this.content,
    required this.timestamp,
    required this.sentimentScore,
  });

  factory ParsedMessage.fromJson(Map<String, dynamic> json) {
    return ParsedMessage(
      author: json['author'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] as int,
      sentimentScore: (json['sentiment_score'] as num).toDouble(),
    );
  }
}

class ParsedParticipant {
  final String name;
  final List<ParsedMessage> messages;

  ParsedParticipant({required this.name, required this.messages});

  factory ParsedParticipant.fromJson(Map<String, dynamic> json) {
    return ParsedParticipant(
      name: json['name'] as String,
      messages: (json['messages'] as List)
          .map((m) => ParsedMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ParsedChat {
  final List<ParsedParticipant> participants;

  ParsedChat({required this.participants});

  factory ParsedChat.fromJson(Map<String, dynamic> json) {
    return ParsedChat(
      participants: (json['participants'] as List)
          .map((p) => ParsedParticipant.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ============================================================================
// ChatParser con FFI a Rust + Fallback a Dart
// ============================================================================

class ChatParserFFI {
  static ffi.DynamicLibrary? _dylib;
  static ParseWhatsAppChatDart? _parseWhatsAppChat;
  static FreeStringDart? _freeString;
  static bool _ffiAvailable = false;
  static ChatParserBatchOptimized? _dartParser; // Parser de respaldo

  ChatParserFFI() {
    _loadLibrary();
  }

  static void _loadLibrary() {
    if (_dylib != null || _dartParser != null) return;

    try {
      // Intentar cargar la librería según la plataforma
      if (Platform.isLinux) {
        _dylib = ffi.DynamicLibrary.open('libchat_rust.so');
      } else if (Platform.isAndroid) {
        // Android maneja las .so automáticamente desde jniLibs
        _dylib = ffi.DynamicLibrary.open('libchat_rust.so');
      } else if (Platform.isWindows) {
        // Intentar cargar DLL para Windows (si la tienes)
        _dylib = ffi.DynamicLibrary.open('libchat_rust.dll');
      } else if (Platform.isMacOS) {
        // Intentar cargar dylib para macOS (si la tienes)
        _dylib = ffi.DynamicLibrary.open('libchat_rust.dylib');
      } else {
        throw UnsupportedError('Platform not supported for FFI');
      }

      // Cargar funciones FFI
      _parseWhatsAppChat = _dylib!
          .lookup<ffi.NativeFunction<ParseWhatsAppChatNative>>(
            'parse_whatsapp_chat_ffi',
          )
          .asFunction();

      _freeString = _dylib!
          .lookup<ffi.NativeFunction<FreeStringNative>>('free_string')
          .asFunction();

      _ffiAvailable = true;
      // print('✅ FFI library loaded successfully for ${Platform.operatingSystem}');
    } catch (e) {
      // Si falla, usar el parser de Dart como fallback
      // print('⚠️ FFI not available: $e');
      // print('📱 Using Dart parser as fallback');
      _dartParser = ChatParserBatchOptimized();
      _ffiAvailable = false;
    }
  }

  ChatAnalysis parse(String content) {
    if (_ffiAvailable && _parseWhatsAppChat != null && _freeString != null) {
      // Usar la versión optimizada de Rust
      return _parseWithFFI(content);
    } else if (_dartParser != null) {
      // Usar el parser de Dart como fallback
      // print('🐌 Parsing with Dart (slower)');
      return _dartParser!.parse(content);
    } else {
      throw StateError('No parser available (neither FFI nor Dart)');
    }
  }

  ChatAnalysis _parseWithFFI(String content) {
    final contentPtr = content.toNativeUtf8();

    try {
      final resultPtr = _parseWhatsAppChat!(contentPtr);

      if (resultPtr.address == 0) {
        throw Exception('Failed to parse chat with FFI');
      }

      try {
        final jsonString = resultPtr.toDartString();
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        final parsedChat = ParsedChat.fromJson(jsonData);
        return _convertToAnalysis(parsedChat);
      } finally {
        _freeString!(resultPtr);
      }
    } finally {
      malloc.free(contentPtr);
    }
  }

  ChatAnalysis _convertToAnalysis(ParsedChat parsedChat) {
    final participants = <ChatParticipant>[];

    for (final parsedParticipant in parsedChat.participants) {
      final participant = ChatParticipant(name: parsedParticipant.name);

      for (final parsedMessage in parsedParticipant.messages) {
        final message = ChatMessage(
          author: parsedMessage.author,
          content: parsedMessage.content,
          dateTime: DateTime.fromMillisecondsSinceEpoch(
            parsedMessage.timestamp,
          ),
          sentimentScore: parsedMessage.sentimentScore,
        );

        participant.messages.add(message);
      }

      participants.add(participant);
    }

    return ChatAnalysis(participants: participants);
  }

  // Método útil para saber qué parser se está usando
  static bool get isUsingFFI => _ffiAvailable;
  
  static String get parserType => _ffiAvailable ? 'Rust FFI' : 'Dart';
}