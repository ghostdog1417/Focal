import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final TextStyle? titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          color: task.isCompleted ? const Color(0xFF9CA3AF) : const Color(0xFF111827),
          fontWeight: FontWeight.w600,
        );

    final TextStyle? descriptionStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: task.isCompleted ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
        );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: onChanged,
          activeColor: const Color(0xFF4B7BEC),
        ),
        title: Text(task.title, style: titleStyle),
        subtitle: (task.description == null || task.description!.trim().isEmpty)
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(task.description!, style: descriptionStyle),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit task',
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete task',
            ),
          ],
        ),
      ),
    );
  }
}
