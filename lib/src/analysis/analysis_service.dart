import '../models/chat_analysis.dart';
import 'chat_parser_rust.dart';

class AnalysisService {
  final _parser = ChatParserFFI();
  final _cache = <String, ChatAnalysis>{};

  /// Processes the chat content, using a cached result if available.
  Future<ChatAnalysis> getAnalysis(
    String chatContent, {
    required String id,
  }) async {
    if (_cache.containsKey(id)) {
      // Return the cached result
      return _cache[id]!;
    }

    // If not in cache, parse, store, and then return
    final analysis = _parser.parse(chatContent);
    _cache[id] = analysis;
    return analysis;
  }

  /// Validates if the provided content is a valid WhatsApp chat.
  /// Returns true if the chat has at least one participant with messages.
  bool isValidWhatsAppChat(String chatContent) {
    if (chatContent.trim().isEmpty) {
      return false;
    }

    try {
      final analysis = _parser.parse(chatContent);
      // Valid if we have at least one participant with at least one message
      return analysis.participants.isNotEmpty &&
          analysis.participants.any((p) => p.messages.isNotEmpty);
    } catch (e) {
      return false;
    }
  }

  /// Clears the analysis cache.
  void clearCache() {
    _cache.clear();
  }
}
