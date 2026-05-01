import '../models/task.dart';

class ReminderSuggestion {
  const ReminderSuggestion({
    required this.hour,
    required this.message,
  });

  final int hour;
  final String message;

  String get formattedTime {
    final int normalizedHour = hour.clamp(0, 23);
    final String period = normalizedHour >= 12 ? 'PM' : 'AM';
    int h = normalizedHour % 12;
    if (h == 0) h = 12;
    return '$h:00 $period';
  }
}

class ReminderIntelligenceService {
  ReminderSuggestion suggestReminder(List<Task> tasks) {
    final List<Task> completed = tasks
        .where((Task task) => task.isCompleted && task.completedAt != null)
        .toList();

    if (completed.isEmpty) {
      return const ReminderSuggestion(
        hour: 18,
        message: 'No pattern yet. Start with a 6:00 PM reminder.',
      );
    }

    final Map<int, int> frequencyByHour = <int, int>{};
    for (final Task task in completed) {
      final int hour = task.completedAt!.hour;
      frequencyByHour[hour] = (frequencyByHour[hour] ?? 0) + 1;
    }

    int bestHour = 18;
    int bestCount = -1;
    frequencyByHour.forEach((int hour, int count) {
      if (count > bestCount) {
        bestCount = count;
        bestHour = hour;
      }
    });

    final int dueSoonCount = tasks.where((Task task) {
      if (task.isCompleted || task.dueDate == null) return false;
      final DateTime now = DateTime.now();
      return task.dueDate!.difference(now).inHours <= 24;
    }).length;

    final String message = dueSoonCount > 0
        ? '$dueSoonCount task(s) due soon. Schedule reminder at ${_formatHour(bestHour)}.'
        : 'Best completion pattern is around ${_formatHour(bestHour)}.';

    return ReminderSuggestion(hour: bestHour, message: message);
  }

  String _formatHour(int hour) {
    final int normalizedHour = hour.clamp(0, 23);
    final String period = normalizedHour >= 12 ? 'PM' : 'AM';
    int h = normalizedHour % 12;
    if (h == 0) h = 12;
    return '$h:00 $period';
  }
}
