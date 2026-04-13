import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'models/task.dart';
import 'screens/home_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/sign_in_screen.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/streak_service.dart';
import 'theme/app_style.dart';
import 'theme/app_theme_builder.dart';
import 'widgets/focal_logo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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
      theme: AppThemeBuilder.buildLightTheme(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          return const SignInScreen();
        }

        return const SplashScreen();
      },
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
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final StreakService _streakService = StreakService();
  final PageController _pageController = PageController();

  List<Task> _tasks = <Task>[];
  bool _isLoading = true;
  int _selectedIndex = 0;
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadStreak();
  }

  Future<void> _loadTasks() async {
    final List<Task> loadedTasks = await _storageService.loadTasks();
    if (!mounted) return;
    setState(() {
      _tasks = loadedTasks;
      _isLoading = false;
    });
  }

  Future<void> _loadStreak() async {
    final int streak = await _streakService.getStreak();
    if (!mounted) return;
    setState(() {
      _currentStreak = streak;
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

  Future<void> _logout() async {
    await _authService.signOut();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
      (Route<dynamic> route) => false,
    );
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
        onLogout: _logout,
        currentStreak: _currentStreak,
      ),
      const TimerScreen(),
      ProgressScreen(
        completedToday: _completedTasksToday(),
        totalTasks: _tasks.length,
      ),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
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
            indicatorColor: const Color(0xFFE3ECFF),
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
