import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/journal_service.dart';
import '../services/planner_service.dart';
import '../services/reminder_notification_service.dart';
import '../services/reminder_intelligence_service.dart';
import '../theme/app_style.dart';
import '../widgets/task_tile.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.tasks,
    required this.isLoading,
    required this.onAddTask,
    required this.onUpdateTask,
    required this.onDeleteTask,
    required this.onToggleTask,
    required this.currentStreak,
    this.onJournalUpdated,
  });

  final List<Task> tasks;
  final bool isLoading;
  final Future<void> Function(Task task) onAddTask;
  final Future<void> Function(Task task) onUpdateTask;
  final Future<void> Function(String id) onDeleteTask;
  final Future<void> Function(String id, bool isCompleted) onToggleTask;
  final int currentStreak;
  final Future<void> Function()? onJournalUpdated;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Task> _visibleTasks = <Task>[];
  final PlannerService _plannerService = PlannerService();
  final ReminderIntelligenceService _reminderService =
      ReminderIntelligenceService();
    final ReminderNotificationService _reminderNotificationService =
      ReminderNotificationService();
  final JournalService _journalService = JournalService();

  List<Task> _topTasks = <Task>[];
  ReminderSuggestion _reminderSuggestion = const ReminderSuggestion(
    hour: 18,
    message: 'No pattern yet. Start with a 6:00 PM reminder.',
  );
  JournalEntry? _todayJournal;
  int? _lastScheduledReminderHour;

  @override
  void initState() {
    super.initState();
    _visibleTasks.addAll(widget.tasks);
    _refreshInsights();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimatedList(widget.tasks);
    _refreshInsights();
  }

  Future<void> _refreshInsights() async {
    final List<Task> planner = _plannerService.suggestTopTasks(widget.tasks);
    final ReminderSuggestion reminder = _reminderService.suggestReminder(widget.tasks);
    final JournalEntry? todayEntry = await _journalService.getTodayEntry();

    if (_lastScheduledReminderHour != reminder.hour) {
      await _reminderNotificationService.scheduleDailyReminder(
        hour: reminder.hour,
        title: 'Focal • ${reminder.formattedTime}',
        body: reminder.message,
      );
      _lastScheduledReminderHour = reminder.hour;
    }

    if (!mounted) return;
    setState(() {
      _topTasks = planner;
      _reminderSuggestion = reminder;
      _todayJournal = todayEntry;
    });
  }

  Future<void> _openJournalPrompt() async {
    final TextEditingController wentWellController = TextEditingController(
      text: _todayJournal?.wentWell ?? '',
    );
    final TextEditingController blockedByController = TextEditingController(
      text: _todayJournal?.blockedBy ?? '',
    );

    final bool? shouldSave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Daily Reflection'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: wentWellController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'What went well?',
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                TextField(
                  controller: blockedByController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'What blocked you?',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (shouldSave == true) {
      await _journalService.saveTodayEntry(
        wentWell: wentWellController.text.trim(),
        blockedBy: blockedByController.text.trim(),
      );
      await _refreshInsights();
      await widget.onJournalUpdated?.call();
    }

    wentWellController.dispose();
    blockedByController.dispose();
  }

  void _syncAnimatedList(List<Task> newTasks) {
    final Set<String> newIds = newTasks.map((Task task) => task.id).toSet();

    for (int i = _visibleTasks.length - 1; i >= 0; i--) {
      final Task task = _visibleTasks[i];
      if (!newIds.contains(task.id)) {
        final Task removedTask = _visibleTasks.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (BuildContext context, Animation<double> animation) {
            return _buildAnimatedTaskTile(removedTask, animation);
          },
          duration: const Duration(milliseconds: 280),
        );
      }
    }

    for (int i = 0; i < newTasks.length; i++) {
      final Task incomingTask = newTasks[i];
      final int existingIndex = _visibleTasks.indexWhere(
        (Task task) => task.id == incomingTask.id,
      );

      if (existingIndex == -1) {
        final int insertIndex = i.clamp(0, _visibleTasks.length);
        _visibleTasks.insert(insertIndex, incomingTask);
        _listKey.currentState?.insertItem(
          insertIndex,
          duration: const Duration(milliseconds: 300),
        );
      } else {
        _visibleTasks[existingIndex] = incomingTask;
      }
    }

    setState(() {});
  }

  Widget _buildAnimatedTaskTile(Task task, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      child: FadeTransition(
        opacity: animation,
        child: TaskTile(
          task: task,
          onChanged: (bool? value) {
            widget.onToggleTask(task.id, value ?? false);
          },
          onEdit: () => _openEditTask(context, task),
          onDelete: () => widget.onDeleteTask(task.id),
        ),
      ),
    );
  }

  Future<void> _openAddTask(BuildContext context) async {
    final Task? task = await Navigator.of(context).push<Task>(
      MaterialPageRoute<Task>(
        builder: (_) => const AddTaskScreen(),
      ),
    );

    if (task != null) {
      await widget.onAddTask(task);
    }
  }

  Future<void> _openEditTask(BuildContext context, Task existingTask) async {
    final Task? updatedTask = await Navigator.of(context).push<Task>(
      MaterialPageRoute<Task>(
        builder: (_) => AddTaskScreen(task: existingTask),
      ),
    );

    if (updatedTask != null) {
      await widget.onUpdateTask(updatedTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int completedCount =
        widget.tasks.where((Task task) => task.isCompleted).length;
    final int pendingCount = widget.tasks.length - completedCount;
    final DateTime today = DateTime.now();
    final int habitsToday = widget.tasks.where((Task task) {
      return task.isHabit && task.isHabitDueOn(today);
    }).length;
    final int completedHabitsToday = widget.tasks.where((Task task) {
      return task.isHabit && task.isHabitDueOn(today) && task.isCompleted;
    }).length;

    final Color surfaceColor = AppColors.surface;
    final Color textPrimary = AppColors.textPrimary;
    final Color textSecondary = AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Today',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s8,
          AppSpacing.s20,
          104,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.progressCardStart, AppColors.progressCardEnd],
                ),
                borderRadius: AppRadius.card,
                border: Border.all(color: AppColors.divider),
                boxShadow: AppShadows.soft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello👋',
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s8),
                            Text(
                              'Let\'s focus today',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.currentStreak > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s12,
                            vertical: AppSpacing.s8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: AppRadius.button,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '🔥',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: AppSpacing.s4),
                              Text(
                                '${widget.currentStreak}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text(
                    'Daily Progress',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    '$completedCount/${widget.tasks.length} completed',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  ClipRRect(
                    borderRadius: AppRadius.small,
                    child: LinearProgressIndicator(
                      value: widget.tasks.isEmpty ? 0 : completedCount / widget.tasks.length,
                      minHeight: 8,
                      backgroundColor: AppColors.progressTrack,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            if (_topTasks.isNotEmpty)
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
                    const Text(
                      'Top 3 Focus Plan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    ..._topTasks.map((Task task) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              color: AppColors.primary,
                              size: 17,
                            ),
                            const SizedBox(width: AppSpacing.s8),
                            Expanded(
                              child: Text(
                                '${task.title} · ${task.estimatedMinutes} min',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            if (_topTasks.isNotEmpty) const SizedBox(height: AppSpacing.s12),
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
                  const Text(
                    'Habits',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    '$completedHabitsToday/$habitsToday completed today',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
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
                  const Text(
                    'Smart Reminder Suggestion',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    _reminderSuggestion.message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    'Scheduled daily at ${_reminderSuggestion.formattedTime}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.card,
                border: Border.all(color: AppColors.divider),
                boxShadow: AppShadows.soft,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Reflection Journal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _openJournalPrompt,
                    child: Text(_todayJournal == null ? 'Write' : 'Edit'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Row(
              children: [
                Text(
                  'Tasks',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '$pendingCount pending',
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: widget.tasks.isEmpty
                        ? Container(
                            key: const ValueKey<String>('empty-state'),
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.s24),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: AppRadius.card,
                              border: Border.all(color: AppColors.divider),
                              boxShadow: AppShadows.soft,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.task_alt_rounded,
                                  size: 44,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: AppSpacing.s12),
                                Text(
                                  'No tasks yet',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s8),
                                Text(
                                  'Start your journey',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : AnimatedList(
                            key: _listKey,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            initialItemCount: _visibleTasks.length,
                            itemBuilder: (
                              BuildContext context,
                              int index,
                              Animation<double> animation,
                            ) {
                              final Task task = _visibleTasks[index];
                              return _buildAnimatedTaskTile(task, animation);
                            },
                          ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTask(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
