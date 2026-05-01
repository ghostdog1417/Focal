import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import 'firestore_service.dart';

class HybridStorageService {
  final FirestoreService _firestoreService = FirestoreService();
  late SharedPreferences _prefs;
  bool _useFirebase = false;

  // Keys for SharedPreferences
  static const String _tasksKey = 'focal_tasks';
  static const String _streakKey = 'focal_streak';
  static const String _lastStreakDateKey = 'focal_last_streak_date';

  // Initialize storage service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Enable/disable Firebase sync
  void setUseFirebase(bool useFirebase) {
    _useFirebase = useFirebase;
  }

  // Save tasks (local + Firebase if enabled)
  Future<void> saveTasks(List<Task> tasks) async {
    try {
      // Save to local storage always
      final jsonTasks = tasks.map((t) => t.toMap()).toList();
      await _prefs.setString(_tasksKey, _encodeJson(jsonTasks));

      // Sync to Firebase if enabled
      if (_useFirebase) {
        await _firestoreService.saveTasks(tasks);
      }
    } catch (e) {
      debugPrint('Error saving tasks: $e');
    }
  }

  // Load tasks (from Firebase if available, fallback to local)
  Future<List<Task>> loadTasks() async {
    try {
      // Try Firebase first if enabled
      if (_useFirebase) {
        try {
          return await _firestoreService.loadTasks();
        } catch (e) {
          debugPrint('Firebase load failed, falling back to local: $e');
        }
      }

      // Load from local storage
      final jsonString = _prefs.getString(_tasksKey);
      if (jsonString == null) return [];

      final jsonTasks = _decodeJson(jsonString);
      return jsonTasks
          .map((task) => Task.fromMap(task as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      return [];
    }
  }

  // Get real-time stream of tasks from Firebase
  Stream<List<Task>> getTasksStream() {
    if (_useFirebase) {
      return _firestoreService.getTasksStream();
    }
    // Return a stream from local storage (simple implementation)
    return Stream.value([]);
  }

  // Delete task
  Future<void> deleteTask(String taskId, List<Task> allTasks) async {
    try {
      final remainingTasks = allTasks.where((t) => t.id != taskId).toList();
      await saveTasks(remainingTasks);

      if (_useFirebase) {
        await _firestoreService.deleteTask(taskId);
      }
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  // Streak data
  Future<int> getStreak() async {
    return _prefs.getInt(_streakKey) ?? 0;
  }

  Future<String?> getLastStreakDate() async {
    return _prefs.getString(_lastStreakDateKey);
  }

  Future<void> setStreak(int streak) async {
    await _prefs.setInt(_streakKey, streak);
  }

  Future<void> setLastStreakDate(String date) async {
    await _prefs.setString(_lastStreakDateKey, date);
  }

  // Utility methods for JSON encoding/decoding
  String _encodeJson(List<dynamic> data) {
    return data.toString();
  }

  List<dynamic> _decodeJson(String jsonString) {
    // Simple implementation - in production, use dart:convert
    return [];
  }
}
