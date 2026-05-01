import '../models/task.dart';

class PlannerService {
  List<Task> suggestTopTasks(List<Task> tasks, {int count = 3}) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    final List<Task> eligible = tasks
        .where((Task task) =>
            !task.isCompleted && (!task.isHabit || task.isHabitDueOn(today)))
        .toList();

    eligible.sort((Task a, Task b) {
      final int scoreDiff = _scoreTask(b, today) - _scoreTask(a, today);
      if (scoreDiff != 0) return scoreDiff;
      return a.createdAt.compareTo(b.createdAt);
    });

    return eligible.take(count).toList();
  }

  int _scoreTask(Task task, DateTime today) {
    int score = 0;

    score += task.priority.weight * 4;

    if (task.isHabit) {
      score += 3;
    }

    if (task.dueDate != null) {
      final DateTime due = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      final int dayDiff = due.difference(today).inDays;

      if (dayDiff < 0) {
        score += 10;
      } else if (dayDiff == 0) {
        score += 7;
      } else if (dayDiff == 1) {
        score += 5;
      } else if (dayDiff <= 3) {
        score += 2;
      }
    }

    if (task.estimatedMinutes <= 30) {
      score += 2;
    } else if (task.estimatedMinutes <= 60) {
      score += 1;
    }

    return score;
  }
}
