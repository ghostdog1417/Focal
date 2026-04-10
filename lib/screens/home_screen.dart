import 'package:flutter/material.dart';

import '../models/task.dart';
import '../widgets/task_tile.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.tasks,
    required this.isLoading,
    required this.onAddTask,
    required this.onUpdateTask,
    required this.onDeleteTask,
    required this.onToggleTask,
  });

  final List<Task> tasks;
  final bool isLoading;
  final Future<void> Function(Task task) onAddTask;
  final Future<void> Function(Task task) onUpdateTask;
  final Future<void> Function(String id) onDeleteTask;
  final Future<void> Function(String id, bool isCompleted) onToggleTask;

  Future<void> _openAddTask(BuildContext context) async {
    final Task? task = await Navigator.of(context).push<Task>(
      MaterialPageRoute<Task>(
        builder: (_) => const AddTaskScreen(),
      ),
    );

    if (task != null) {
      await onAddTask(task);
    }
  }

  Future<void> _openEditTask(BuildContext context, Task existingTask) async {
    final Task? updatedTask = await Navigator.of(context).push<Task>(
      MaterialPageRoute<Task>(
        builder: (_) => AddTaskScreen(task: existingTask),
      ),
    );

    if (updatedTask != null) {
      await onUpdateTask(updatedTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : tasks.isEmpty
                ? const Center(
                    child: Text(
                      'No tasks yet.\nTap + to add your first task!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 88),
                    itemCount: tasks.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Task task = tasks[index];
                      return TaskTile(
                        task: task,
                        onChanged: (bool? value) {
                          onToggleTask(task.id, value ?? false);
                        },
                        onEdit: () => _openEditTask(context, task),
                        onDelete: () => onDeleteTask(task.id),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTask(context),
        backgroundColor: const Color(0xFF4B7BEC),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
