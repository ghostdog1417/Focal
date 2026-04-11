import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_style.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  static const int focusDuration = 25 * 60;
  static const int breakDuration = 5 * 60;

  Timer? _timer;
  int _remainingSeconds = focusDuration;
  bool _isRunning = false;
  bool _isFocusMode = true;

  void _startOrPauseTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
      });
      return;
    }

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        setState(() {
          _isRunning = false;
          _isFocusMode = !_isFocusMode;
          _remainingSeconds = _isFocusMode ? focusDuration : breakDuration;
        });
        return;
      }

      setState(() {
        _remainingSeconds--;
      });
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isFocusMode = true;
      _remainingSeconds = focusDuration;
    });
  }

  String _formatTime(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    final String mm = minutes.toString().padLeft(2, '0');
    final String ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _isFocusMode
        ? _remainingSeconds / focusDuration
        : _remainingSeconds / breakDuration;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Study Timer',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Focus Mode',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                _isFocusMode ? 'Deep work session in progress' : 'Take a short recharge break',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s24),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.card,
                    border: Border.all(color: AppColors.divider),
                    boxShadow: AppShadows.soft,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 240,
                          width: 240,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 280),
                                width: 190,
                                height: 190,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (_isFocusMode
                                          ? AppColors.primary
                                          : AppColors.accentGreen)
                                      .withValues(alpha: 0.10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isFocusMode
                                              ? AppColors.primary
                                              : AppColors.accentGreen)
                                          .withValues(alpha: 0.16),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 210,
                                width: 210,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 11,
                                  backgroundColor: const Color(0xFFE7EBF3),
                                  color: _isFocusMode
                                      ? AppColors.primary
                                      : AppColors.accentGreen,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatTime(_remainingSeconds),
                                    style: const TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.s8),
                                  Text(
                                    _isFocusMode ? 'Focus Session' : 'Break Time',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s16),
                        const Text(
                          'Pomodoro: 25 min focus • 5 min break',
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isRunning ? null : _startOrPauseTimer,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                      ),
                      child: const Text('Start'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isRunning ? _startOrPauseTimer : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF2C3652),
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                      ),
                      child: const Text('Pause'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetTimer,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.divider),
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
