import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage daily task completion streaks.
/// Tracks consecutive days with at least one completed task.
class StreakService {
  static const String _streakKey = 'study_buddy_streak';
  static const String _lastStreakDateKey = 'study_buddy_last_streak_date';

  /// Get the current streak count.
  Future<int> getStreak() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  /// Get the last date when the streak was updated.
  Future<DateTime?> getLastStreakDate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? dateString = prefs.getString(_lastStreakDateKey);
    if (dateString == null) return null;
    return DateTime.tryParse(dateString);
  }

  /// Update streak based on whether task was completed today.
  /// Returns the new streak count.
  Future<int> updateStreak(bool taskCompletedToday) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int currentStreak = prefs.getInt(_streakKey) ?? 0;
    final String? lastDateString = prefs.getString(_lastStreakDateKey);
    final DateTime lastDate =
        lastDateString != null ? DateTime.parse(lastDateString) : DateTime(2000);

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime lastDateNormalized =
        DateTime(lastDate.year, lastDate.month, lastDate.day);

    int newStreak = currentStreak;

    if (!taskCompletedToday) {
      // No task completed today, reset streak
      newStreak = 0;
    } else if (lastDateNormalized == today) {
      // Same day, keep the same streak (don't increment twice)
      newStreak = currentStreak;
    } else if (lastDateNormalized.add(const Duration(days: 1)) == today) {
      // Next consecutive day, increment streak
      newStreak = currentStreak + 1;
    } else {
      // Gap in days, reset streak and start fresh
      newStreak = 1;
    }

    await prefs.setInt(_streakKey, newStreak);
    await prefs.setString(_lastStreakDateKey, today.toIso8601String());

    return newStreak;
  }

  /// Reset streak to 0 (for testing or manual reset).
  Future<void> resetStreak() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakKey, 0);
    await prefs.remove(_lastStreakDateKey);
  }
}
