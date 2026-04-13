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
  final TextEditingController _estimatedMinutesController =
      TextEditingController();
  late TaskCategory _selectedCategory;
  late TaskPriority _selectedPriority;
  DateTime? _dueDate;
  bool _isHabit = false;
  HabitFrequency _habitFrequency = HabitFrequency.daily;
  late Set<int> _customWeekdays;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.task?.category ?? TaskCategory.study;
    _selectedPriority = widget.task?.priority ?? TaskPriority.medium;
    _dueDate = widget.task?.dueDate;
    _isHabit = widget.task?.isHabit ?? false;
    _habitFrequency = widget.task?.habitFrequency ?? HabitFrequency.daily;
    _customWeekdays = (widget.task?.customWeekdays ?? const <int>[]).toSet();
    _estimatedMinutesController.text =
        (widget.task?.estimatedMinutes ?? 30).toString();

    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedMinutesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();
    final int estimatedMinutes =
        int.tryParse(_estimatedMinutesController.text.trim()) ?? 30;

    final Task task = widget.task == null
        ? Task(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: title,
            description: description.isEmpty ? null : description,
            category: _selectedCategory,
            priority: _selectedPriority,
            dueDate: _dueDate,
            estimatedMinutes: estimatedMinutes,
            isHabit: _isHabit,
            habitFrequency: _habitFrequency,
            customWeekdays: _customWeekdays.toList()..sort(),
            createdAt: DateTime.now(),
          )
        : widget.task!.copyWith(
            title: title,
            description: description.isEmpty ? null : description,
            category: _selectedCategory,
            priority: _selectedPriority,
            dueDate: _dueDate,
            clearDueDate: _dueDate == null,
            estimatedMinutes: estimatedMinutes,
            isHabit: _isHabit,
            habitFrequency: _habitFrequency,
            customWeekdays: _customWeekdays.toList()..sort(),
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
                Text(
                  'Priority',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                DropdownButtonFormField<TaskPriority>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Task priority',
                  ),
                  items: TaskPriority.values
                      .map(
                        (TaskPriority p) => DropdownMenuItem<TaskPriority>(
                          value: p,
                          child: Text(p.display),
                        ),
                      )
                      .toList(),
                  onChanged: (TaskPriority? value) {
                    if (value == null) return;
                    setState(() => _selectedPriority = value);
                  },
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
                      const SizedBox(height: AppSpacing.s16),
                      TextFormField(
                        controller: _estimatedMinutesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Estimated minutes',
                          hintText: '30',
                        ),
                        validator: (String? value) {
                          final int? minutes = int.tryParse(value ?? '');
                          if (minutes == null || minutes <= 0) {
                            return 'Enter a valid duration';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _dueDate == null
                                ? 'No due date set'
                                : 'Due: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.s8),
                          Wrap(
                            alignment: WrapAlignment.end,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: AppSpacing.s4,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  final DateTime now = DateTime.now();
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(now.year - 1),
                                    lastDate: DateTime(now.year + 5),
                                    initialDate: _dueDate ?? now,
                                  );
                                  if (!mounted) return;
                                  if (picked != null) {
                                    setState(() => _dueDate = picked);
                                  }
                                },
                                child: const Text('Set due date'),
                              ),
                              if (_dueDate != null)
                                IconButton(
                                  tooltip: 'Clear due date',
                                  onPressed: () {
                                    if (!mounted) return;
                                    setState(() => _dueDate = null);
                                  },
                                  icon: const Icon(Icons.clear),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _isHabit,
                        title: const Text('Treat as habit'),
                        subtitle: const Text('Repeats based on selected frequency'),
                        onChanged: (bool value) {
                          setState(() => _isHabit = value);
                        },
                      ),
                      if (_isHabit)
                        DropdownButtonFormField<HabitFrequency>(
                          value: _habitFrequency,
                          decoration: const InputDecoration(
                            labelText: 'Habit frequency',
                          ),
                          items: HabitFrequency.values
                              .map(
                                (HabitFrequency h) =>
                                    DropdownMenuItem<HabitFrequency>(
                                  value: h,
                                  child: Text(h.display),
                                ),
                              )
                              .toList(),
                          onChanged: (HabitFrequency? value) {
                            if (value == null) return;
                            setState(() {
                              _habitFrequency = value;
                              if (_habitFrequency == HabitFrequency.custom &&
                                  _customWeekdays.isEmpty) {
                                _customWeekdays.add(DateTime.now().weekday);
                              }
                            });
                          },
                        ),
                      if (_isHabit && _habitFrequency == HabitFrequency.custom)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.s12),
                          child: Wrap(
                            spacing: AppSpacing.s8,
                            runSpacing: AppSpacing.s8,
                            children: _weekdayOptions().map((MapEntry<int, String> item) {
                              final bool selected = _customWeekdays.contains(item.key);
                              return FilterChip(
                                label: Text(item.value),
                                selected: selected,
                                onSelected: (bool value) {
                                  setState(() {
                                    if (value) {
                                      _customWeekdays.add(item.key);
                                    } else {
                                      _customWeekdays.remove(item.key);
                                    }
                                  });
                                },
                              );
                            }).toList(),
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

  List<MapEntry<int, String>> _weekdayOptions() {
    return const <MapEntry<int, String>>[
      MapEntry<int, String>(DateTime.monday, 'Mon'),
      MapEntry<int, String>(DateTime.tuesday, 'Tue'),
      MapEntry<int, String>(DateTime.wednesday, 'Wed'),
      MapEntry<int, String>(DateTime.thursday, 'Thu'),
      MapEntry<int, String>(DateTime.friday, 'Fri'),
      MapEntry<int, String>(DateTime.saturday, 'Sat'),
      MapEntry<int, String>(DateTime.sunday, 'Sun'),
    ];
  }
}
