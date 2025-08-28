import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/chat_analysis.dart';
import 'chat_parser.dart';

class AnalysisService {
  final _parser = ChatParser();
  final _cache = <String, ChatAnalysis>{};

  /// Processes the chat content, using a cached result if available.
  Future<ChatAnalysis> getAnalysis(String chatContent) async {
    final hash = _generateHash(chatContent);

    if (_cache.containsKey(hash)) {
      // Return the cached result
      return _cache[hash]!;
    }

    // If not in cache, parse, store, and then return
    final analysis = _parser.parse(chatContent);
    _cache[hash] = analysis;
    return analysis;
  }

  /// Generates a SHA-256 hash of the given content.
  String _generateHash(String content) {
    final bytes = utf8.encode(content); // Convert content to bytes
    final digest = sha256.convert(bytes); // Generate the hash
    return digest.toString();
  }

  /// Clears the analysis cache.
  void clearCache() {
    _cache.clear();
  }
}
