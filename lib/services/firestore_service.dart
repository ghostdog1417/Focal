import 'package:flutter/foundation.dart' show debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String tasksCollection = 'tasks';

  // Save task
  Future<void> saveTask(Task task) async {
    try {
      await _db.collection(tasksCollection).doc(task.id).set(task.toMap());
    } catch (e) {
      debugPrint('Error saving task: $e');
      rethrow;
    }
  }

  // Load all tasks
  Future<List<Task>> loadTasks() async {
    try {
      final snapshot = await _db.collection(tasksCollection).get();
      return snapshot.docs
          .map((doc) => Task.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      return [];
    }
  }

  // Stream of tasks (real-time updates)
  Stream<List<Task>> getTasksStream() {
    return _db.collection(tasksCollection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromMap(doc.data()))
          .toList();
    });
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      await _db.collection(tasksCollection).doc(taskId).delete();
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  // Update task
  Future<void> updateTask(Task task) async {
    try {
      await _db.collection(tasksCollection).doc(task.id).update(task.toMap());
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  // Batch save tasks
  Future<void> saveTasks(List<Task> tasks) async {
    try {
      final batch = _db.batch();
      for (final task in tasks) {
        batch.set(
          _db.collection(tasksCollection).doc(task.id),
          task.toMap(),
        );
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error batch saving tasks: $e');
      rethrow;
    }
  }
}
