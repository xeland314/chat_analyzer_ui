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

  /// Clears the analysis cache.
  void clearCache() {
    _cache.clear();
  }
}
