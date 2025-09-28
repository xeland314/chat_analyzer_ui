import 'package:flutter/material.dart';
import '../common/time_to_text.dart';
import '../chat/chat_avatar.dart';

class ResponseTimeChart extends StatelessWidget {
  final Map<String, Duration> responseTimes;

  const ResponseTimeChart({super.key, required this.responseTimes});

  @override
  Widget build(BuildContext context) {
    if (responseTimes.isEmpty) return const SizedBox.shrink();

    final entries = responseTimes.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final maxDuration = entries.isNotEmpty
        ? entries.map((e) => e.value).reduce((a, b) => a > b ? a : b)
        : Duration.zero;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Average Response Time',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...entries.map((entry) {
          final durationInMinutes = entry.value.inSeconds / 60.0;
          final proportion = maxDuration.inSeconds > 0
              ? entry.value.inSeconds / maxDuration.inSeconds
              : 0.0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                SizedBox(width: 50, child: authorAvatar(entry.key)),
                const SizedBox(width: 8),
                Expanded(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: proportion,
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          formatDuration(
                            Duration(seconds: (durationInMinutes * 60).toInt()),
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
