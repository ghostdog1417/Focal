import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_style.dart';

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
    final bool hasDescription =
        task.description != null && task.description!.trim().isNotEmpty;

    final Color surfaceColor = AppColors.surface;
    final Color textPrimary = AppColors.textPrimary;
    final Color textSecondary = AppColors.textSecondary;
    final Color dividerColor = AppColors.divider;
    const Color completedBg = Color(0xFFF2FBF3);
    const Color completedBorder = Color(0xFFCBE8CF);
    const Color completedText = Color(0xFF2D7A31);

    // Get category colors
    final Color categoryBgColor = _getCategoryBgColor(task.category);

    final TextStyle? titleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          color: task.isCompleted ? textSecondary : textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.3,
        );

    final TextStyle? descriptionStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: task.isCompleted ? const Color(0xFF9CA3AF) : textSecondary,
          fontSize: 13,
          height: 1.3,
        );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      decoration: BoxDecoration(
        color: task.isCompleted ? completedBg : surfaceColor,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: task.isCompleted ? completedBorder : dividerColor,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        borderRadius: AppRadius.card,
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          leading: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: task.isCompleted ? 1.08 : 1,
            child: Checkbox(
              value: task.isCompleted,
              onChanged: onChanged,
              activeColor: AppColors.accentGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      style: titleStyle ?? const TextStyle(),
                      child: Text(task.title),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s8,
                      vertical: AppSpacing.s4,
                    ),
                    decoration: BoxDecoration(
                      color: categoryBgColor,
                      borderRadius: AppRadius.small,
                    ),
                    child: Text(
                      task.category.emoji,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              if (hasDescription)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: task.isCompleted ? 0.72 : 1,
                    child: Text(task.description!, style: descriptionStyle),
                  ),
                ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: task.isCompleted
                    ? Container(
                        key: ValueKey<String>('done-${task.id}'),
                        margin: const EdgeInsets.only(top: 7),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDFF2E0),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: completedText,
                          ),
                        ),
                      )
                    : const SizedBox(key: ValueKey<String>('not-done')),
              ),
            ],
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
      ),
    );
  }

  Color _getCategoryBgColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.study:
        return CategoryColors.studyLight.withValues(alpha: 0.15);
      case TaskCategory.assignment:
        return CategoryColors.assignmentLight.withValues(alpha: 0.15);
      case TaskCategory.revision:
        return CategoryColors.revisionLight.withValues(alpha: 0.15);
    }
  }
}
