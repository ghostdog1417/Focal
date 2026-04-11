import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class StorageService {
  static const String _tasksKey = 'study_buddy_tasks';

  // --- Task Management ---

  Future<void> saveTasks(List<Task> tasks) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedTasks = jsonEncode(
      tasks.map((Task task) => task.toMap()).toList(),
    );
    await prefs.setString(_tasksKey, encodedTasks);
  }

  Future<List<Task>> loadTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? encodedTasks = prefs.getString(_tasksKey);

    if (encodedTasks == null || encodedTasks.isEmpty) {
      return <Task>[];
    }

    final List<dynamic> decodedList = jsonDecode(encodedTasks) as List<dynamic>;
    return decodedList
        .map((dynamic item) => Task.fromMap(item as Map<String, dynamic>))
        .toList();
  }

}
