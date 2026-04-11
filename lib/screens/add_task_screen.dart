import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_style.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key, this.task});

  final Task? task;

  bool get isEditing => task != null;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late TaskCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.task?.category ?? TaskCategory.study;
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();

    final Task task = widget.task == null
        ? Task(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: title,
            description: description.isEmpty ? null : description,
            category: _selectedCategory,
            createdAt: DateTime.now(),
          )
        : widget.task!.copyWith(
            title: title,
            description: description.isEmpty ? null : description,
            category: _selectedCategory,
          );

    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Task' : 'Add Task'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s12,
            AppSpacing.s20,
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.s20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.isEditing ? 'Edit Task' : 'Add New Task',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.s8),
                const Text(
                  'Capture your next step clearly and keep momentum going.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.s16),
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Wrap(
                  spacing: AppSpacing.s8,
                  children: TaskCategory.values.map((TaskCategory category) {
                    final bool isSelected = _selectedCategory == category;
                    final Color selectionColor = _getCategoryColor(category);
                    
                    return FilterChip(
                      label: Text(
                        '${category.emoji} ${category.display}',
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedCategory = category);
                      },
                      selectedColor: selectionColor.withValues(alpha: 0.25),
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        color: isSelected ? selectionColor : AppColors.divider,
                        width: isSelected ? 2 : 1,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.s16),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.card,
                    border: Border.all(color: AppColors.divider),
                    boxShadow: AppShadows.soft,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Task title',
                          hintText: 'Read chapter 5',
                          hintStyle: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      TextFormField(
                        controller: _descriptionController,
                        minLines: 4,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                          hintText: 'Add notes or details for this task',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                  ),
                  child: Text(widget.isEditing ? 'Save Changes' : 'Add Task'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.study:
        return CategoryColors.studyLight;
      case TaskCategory.assignment:
        return CategoryColors.assignmentLight;
      case TaskCategory.revision:
        return CategoryColors.revisionLight;
    }
  }
}
