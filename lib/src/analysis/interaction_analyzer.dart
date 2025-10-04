import '../models/chat_message.dart';

/// Represents a block of conversation, segmented by a time threshold.
class Conversation {
  final List<ChatMessage> messages;

  Conversation({required this.messages});

  DateTime? get startTime =>
      messages.isNotEmpty ? messages.first.dateTime : null;
  DateTime? get endTime => messages.isNotEmpty ? messages.last.dateTime : null;

  Duration get duration {
    if (startTime == null || endTime == null) {
      return Duration.zero;
    }
    return endTime!.difference(startTime!);
  }

  List<String> get participants =>
      messages.map((m) => m.author).toSet().toList();
}

/// Analyzes interactions within a chat, such as conversation segmentation.
class InteractionAnalyzer {
  final List<ChatMessage> _messages;

  // The natural threshold is expensive to calculate, so we cache it.
  double? _naturalThreshold;

  InteractionAnalyzer(List<ChatMessage> messages)
    // Ensure messages are sorted by date, which is crucial for all analysis.
    : _messages = List.from(messages)
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  /// Estimates the natural conversation break threshold in minutes using a percentile.
  ///
  /// This method calculates all the time gaps between consecutive messages and finds the
  /// value at the specified [percentile] to determine a "natural" break point.
  double estimateNaturalThreshold({double percentile = 90.0}) {
    if (_naturalThreshold != null) return _naturalThreshold!;

    if (_messages.length < 2) {
      _naturalThreshold = 60.0; // Default fallback for very short chats.
      return _naturalThreshold!;
    }

    // 1. Calculate all time gaps in minutes.
    final gapsInMinutes = <double>[];
    for (int i = 1; i < _messages.length; i++) {
      final duration = _messages[i].dateTime.difference(
        _messages[i - 1].dateTime,
      );
      gapsInMinutes.add(duration.inSeconds / 60.0);
    }

    if (gapsInMinutes.isEmpty) {
      _naturalThreshold = 60.0; // Another fallback.
      return _naturalThreshold!;
    }

    // 2. Sort the gaps to prepare for percentile calculation.
    gapsInMinutes.sort();

    // 3. Calculate the percentile value with linear interpolation.
    final index = (percentile / 100) * (gapsInMinutes.length - 1);
    final lower = index.floor();
    final upper = index.ceil();

    if (lower == upper) {
      _naturalThreshold = gapsInMinutes[lower];
    } else {
      // Simple linear interpolation.
      final weight = index - lower;
      _naturalThreshold =
          gapsInMinutes[lower] * (1 - weight) + gapsInMinutes[upper] * weight;
    }

    // We can round it to a reasonable number of decimal places.
    _naturalThreshold = (_naturalThreshold! * 100).round() / 100;

    return _naturalThreshold!;
  }

  /// Segments the chat into a list of [Conversation] objects based on an inactivity threshold.
  ///
  /// If [thresholdInMinutes] is not provided, the `estimateNaturalThreshold` is used automatically.
  List<Conversation> segmentConversations({double? thresholdInMinutes}) {
    final threshold = thresholdInMinutes ?? estimateNaturalThreshold();
    final thresholdDuration = Duration(
      microseconds: (threshold * 60 * 1000 * 1000).round(),
    );

    if (_messages.isEmpty) return [];

    final conversations = <Conversation>[];
    var currentConversationMessages = <ChatMessage>[];

    for (final message in _messages) {
      if (currentConversationMessages.isEmpty) {
        currentConversationMessages.add(message);
        continue;
      }

      final lastMessageTime = currentConversationMessages.last.dateTime;
      final gap = message.dateTime.difference(lastMessageTime);

      if (gap > thresholdDuration) {
        // Close current conversation and start a new one.
        conversations.add(
          Conversation(messages: List.from(currentConversationMessages)),
        );
        currentConversationMessages = [message]; // Start new one.
      } else {
        currentConversationMessages.add(message);
      }
    }

    // Add the last conversation to the list.
    if (currentConversationMessages.isNotEmpty) {
      conversations.add(
        Conversation(messages: List.from(currentConversationMessages)),
      );
    }

    return conversations;
  }

  /// Calculates a map of participant names to the number of conversations they started.
  Map<String, int> calculateConversationStarters(
    List<Conversation> conversations,
  ) {
    final starters = <String, int>{};
    for (final conv in conversations) {
      if (conv.messages.isNotEmpty) {
        final starterName = conv.messages.first.author;
        starters[starterName] = (starters[starterName] ?? 0) + 1;
      }
    }
    return starters;
  }

  /// Calculates a map of participant names to the number of conversations they ended.
  Map<String, int> calculateConversationEnders(
    List<Conversation> conversations,
  ) {
    final enders = <String, int>{};
    for (final conv in conversations) {
      if (conv.messages.isNotEmpty) {
        final enderName = conv.messages.last.author;
        enders[enderName] = (enders[enderName] ?? 0) + 1;
      }
    }
    return enders;
  }

  /// Calculates who replies to whom and the average response time for each participant.
  ///
  /// A "reply" is counted when a user sends a message after another user, within the
  /// provided [thresholdInMinutes].
  ({
    Map<String, Map<String, int>> whoRepliesToWhom,
    Map<String, Duration> averageResponseTime,
  })
  calculateInteractionMetrics({double? thresholdInMinutes}) {
    final threshold = thresholdInMinutes ?? estimateNaturalThreshold();
    final thresholdDuration = Duration(
      microseconds: (threshold * 60 * 1000 * 1000).round(),
    );

    final whoRepliesToWhom = <String, Map<String, int>>{};
    final responseTimes = <String, List<Duration>>{};

    for (int i = 1; i < _messages.length; i++) {
      final previousMessage = _messages[i - 1];
      final currentMessage = _messages[i];

      final replier = currentMessage.author;
      final repliee = previousMessage.author;


        final responseDuration = currentMessage.dateTime.difference(
          previousMessage.dateTime,
        );

        // And it must be within the conversation threshold to be a valid reply.
        if (responseDuration <= thresholdDuration) {
          // Increment reply count.
          final replierMap = whoRepliesToWhom.putIfAbsent(replier, () => {});
          replierMap[repliee] = (replierMap[repliee] ?? 0) + 1;

          // Add response time for averaging later.
          if (replier != repliee) {
            responseTimes.putIfAbsent(replier, () => []).add(responseDuration);
          }
        }
    }
    final averageResponseTime = <String, Duration>{};
    responseTimes.forEach((participant, durations) {
      if (durations.isNotEmpty) {
        final totalMicroseconds = durations.fold(
          0,
          (sum, d) => sum + d.inMicroseconds,
        );
        final averageMicroseconds = totalMicroseconds ~/ durations.length;
        averageResponseTime[participant] = Duration(
          microseconds: averageMicroseconds,
        );
      }
    });

    return (
      whoRepliesToWhom: whoRepliesToWhom,
      averageResponseTime: averageResponseTime,
    );
  }
}
