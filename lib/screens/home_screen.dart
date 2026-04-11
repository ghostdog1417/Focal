import 'package:flutter/material.dart';

import '../models/task.dart';
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
    required this.onLogout,
    required this.currentStreak,
  });

  final List<Task> tasks;
  final bool isLoading;
  final Future<void> Function(Task task) onAddTask;
  final Future<void> Function(Task task) onUpdateTask;
  final Future<void> Function(String id) onDeleteTask;
  final Future<void> Function(String id, bool isCompleted) onToggleTask;
  final Future<void> Function() onLogout;
  final int currentStreak;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Task> _visibleTasks = <Task>[];

  @override
  void initState() {
    super.initState();
    _visibleTasks.addAll(widget.tasks);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimatedList(widget.tasks);
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

    final Color surfaceColor = AppColors.surface;
    final Color textPrimary = AppColors.textPrimary;
    final Color textSecondary = AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Today',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: widget.onLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s8,
          AppSpacing.s20,
          0,
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
                border: Border.all(color: const Color(0xFFD8E3FA)),
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
                              'Hello, Srijan 👋',
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
                      backgroundColor: const Color(0xFFDCE4F4),
                      color: AppColors.primary,
                    ),
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
            Expanded(
              child: widget.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: widget.tasks.isEmpty
                          ? Center(
                              key: const ValueKey<String>('empty-state'),
                              child: Container(
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
                              ),
                            )
                          : AnimatedList(
                              key: _listKey,
                              padding: const EdgeInsets.only(bottom: 104),
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
