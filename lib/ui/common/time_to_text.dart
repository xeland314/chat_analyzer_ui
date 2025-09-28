String formatDuration(Duration duration) {
  if (duration.inDays > 0) {
    final hours = duration.inHours % 24;
    if (hours > 0) {
      return '${duration.inDays}d ${hours}h';
    }
    final minutes = duration.inMinutes % 60;
    if (minutes > 0) {
      return '${duration.inDays}d ${minutes}min';
    }
    return '${duration.inDays}d ${duration.inSeconds % 60}s';
  } else if (duration.inHours > 0) {
    final minutes = duration.inMinutes % 60;
    if (minutes > 0) {
      return '${duration.inHours}h ${minutes}min';
    }
    return '${duration.inHours}h ${duration.inSeconds % 60}s';
  } else if (duration.inMinutes > 0) {
    return '${duration.inMinutes}min ${duration.inSeconds % 60}s';
  } else {
    return '${duration.inSeconds}s';
  }
}