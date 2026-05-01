import 'package:flutter/material.dart';

import 'models/task.dart';
import 'screens/home_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/timer_screen.dart';
import 'services/focus_analytics_service.dart';
import 'services/journal_service.dart';
import 'services/storage_service.dart';
import 'services/streak_service.dart';
import 'theme/app_style.dart';
import 'theme/app_theme_builder.dart';
import 'widgets/focal_logo.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FocalApp());
}

class FocalApp extends StatefulWidget {
  const FocalApp({super.key});

  @override
  State<FocalApp> createState() => _FocalAppState();
}

class _FocalAppState extends State<FocalApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Focal',
      theme: AppThemeBuilder.buildDarkTheme(),
      darkTheme: AppThemeBuilder.buildDarkTheme(),
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _goToHome();
  }

  Future<void> _goToHome() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const MainNavigationScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.progressCardStart, AppColors.background],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FocalLogo(size: 72),
                const SizedBox(height: 16),
                const Text(
                  'Focal',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Smart Task & Study Tracker',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final StorageService _storageService = StorageService();
  final StreakService _streakService = StreakService();
  final FocusAnalyticsService _focusAnalyticsService = FocusAnalyticsService();
  final JournalService _journalService = JournalService();
  final PageController _pageController = PageController();

  List<Task> _tasks = <Task>[];
  bool _isLoading = true;
  int _selectedIndex = 0;
  int _currentStreak = 0;
  int _focusMinutesToday = 0;
  List<int> _weeklyFocusMinutes = List<int>.filled(7, 0);
  List<JournalEntry> _weeklyJournalEntries = <JournalEntry>[];
  bool _isStrictFocusLocked = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadStreak();
    _loadFocusInsights();
    _loadJournalInsights();
  }

  Future<void> _loadTasks() async {
    final List<Task> loadedTasks = await _storageService.loadTasks();
    final List<Task> normalizedTasks = _rolloverHabitsIfNeeded(loadedTasks);

    if (normalizedTasks != loadedTasks) {
      await _storageService.saveTasks(normalizedTasks);
    }

    if (!mounted) return;
    setState(() {
      _tasks = normalizedTasks;
      _isLoading = false;
    });
  }

  List<Task> _rolloverHabitsIfNeeded(List<Task> tasks) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    bool changed = false;

    final List<Task> updated = tasks.map((Task task) {
      if (!task.isHabit || !task.isCompleted || task.completedAt == null) {
        return task;
      }

      final DateTime completedDay = DateTime(
        task.completedAt!.year,
        task.completedAt!.month,
        task.completedAt!.day,
      );

      if (completedDay == today) {
        return task;
      }

      if (!task.isHabitDueOn(today)) {
        return task;
      }

      changed = true;
      return task.copyWith(
        isCompleted: false,
        clearCompletedAt: true,
      );
    }).toList();

    return changed ? updated : tasks;
  }

  Future<void> _loadStreak() async {
    final int streak = await _streakService.getStreak();
    if (!mounted) return;
    setState(() {
      _currentStreak = streak;
    });
  }

  Future<void> _loadFocusInsights() async {
    final int todayMinutes = await _focusAnalyticsService.getTodayFocusMinutes();
    final List<int> weeklyMinutes =
        await _focusAnalyticsService.getLast7DaysFocusMinutes();

    if (!mounted) return;
    setState(() {
      _focusMinutesToday = todayMinutes;
      _weeklyFocusMinutes = weeklyMinutes;
    });
  }

  Future<void> _loadJournalInsights() async {
    final List<JournalEntry> entries = await _journalService.getLast7Entries();
    if (!mounted) return;
    setState(() {
      _weeklyJournalEntries = entries;
    });
  }

  Future<void> _saveTasks() async {
    await _storageService.saveTasks(_tasks);
  }

  Future<void> _addTask(Task task) async {
    setState(() {
      _tasks = <Task>[..._tasks, task];
    });
    await _saveTasks();
  }

  Future<void> _updateTask(Task task) async {
    final int index = _tasks.indexWhere((Task t) => t.id == task.id);
    if (index == -1) return;
    setState(() {
      _tasks[index] = task;
    });
    await _saveTasks();
  }

  Future<void> _deleteTask(String id) async {
    setState(() {
      _tasks.removeWhere((Task task) => task.id == id);
    });
    await _saveTasks();
  }

  Future<void> _toggleTask(String id, bool isCompleted) async {
    final int index = _tasks.indexWhere((Task t) => t.id == id);
    if (index == -1) return;

    final Task oldTask = _tasks[index];
    _tasks[index] = oldTask.copyWith(
      isCompleted: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
    );
    
    // Update streak if task was completed
    if (isCompleted) {
      await _streakService.updateStreak(true);
      await _loadStreak();
    }
    
    setState(() {});
    await _saveTasks();
  }

  int _completedTasksToday() {
    final DateTime now = DateTime.now();
    return _tasks.where((Task task) {
      if (!task.isCompleted || task.completedAt == null) return false;
      final DateTime completed = task.completedAt!;
      return completed.year == now.year &&
          completed.month == now.month &&
          completed.day == now.day;
    }).length;
  }

  List<int> _completedTasksLast7Days() {
    final DateTime now = DateTime.now();
    return List<int>.generate(7, (int index) {
      final DateTime day =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - index));
      return _tasks.where((Task task) {
        if (!task.isCompleted || task.completedAt == null) return false;
        final DateTime completed = task.completedAt!;
        return completed.year == day.year &&
            completed.month == day.month &&
            completed.day == day.day;
      }).length;
    });
  }

  Future<void> _onFocusSessionCompleted(int minutes) async {
    await _focusAnalyticsService.addFocusMinutes(DateTime.now(), minutes);
    await _loadFocusInsights();
  }

  void _onStrictFocusLockChanged(bool isLocked) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isStrictFocusLocked == isLocked) return;
      setState(() {
        _isStrictFocusLocked = isLocked;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = <Widget>[
      HomeScreen(
        tasks: _tasks,
        isLoading: _isLoading,
        onAddTask: _addTask,
        onUpdateTask: _updateTask,
        onDeleteTask: _deleteTask,
        onToggleTask: _toggleTask,
        currentStreak: _currentStreak,
        onJournalUpdated: _loadJournalInsights,
      ),
      TimerScreen(
        onStrictFocusLockChanged: _onStrictFocusLockChanged,
        onFocusSessionCompleted: (int minutes) {
          _onFocusSessionCompleted(minutes);
        },
      ),
      ProgressScreen(
        completedToday: _completedTasksToday(),
        totalTasks: _tasks.length,
        focusMinutesToday: _focusMinutesToday,
        weeklyFocusMinutes: _weeklyFocusMinutes,
        weeklyCompletedTasks: _completedTasksLast7Days(),
        weeklyJournalEntries: _weeklyJournalEntries,
      ),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: _isStrictFocusLocked
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        onPageChanged: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: screens,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: NavigationBar(
            height: 70,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              if (_isStrictFocusLocked && index != 1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Strict Focus is active. Finish or pause the timer first.'),
                  ),
                );
                return;
              }

              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
              );
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.navIndicator,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.checklist_rounded),
                label: 'Tasks',
              ),
              NavigationDestination(
                icon: Icon(Icons.timer_outlined),
                label: 'Timer',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                label: 'Progress',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
