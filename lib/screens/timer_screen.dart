import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_style.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({
    super.key,
    this.onStrictFocusLockChanged,
    this.onFocusSessionCompleted,
  });

  final void Function(bool isLocked)? onStrictFocusLockChanged;
  final void Function(int focusMinutes)? onFocusSessionCompleted;

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  static const int _defaultFocusMinutes = 25;
  static const int _defaultBreakMinutes = 5;

  Timer? _timer;
  int _focusDurationSeconds = _defaultFocusMinutes * 60;
  int _breakDurationSeconds = _defaultBreakMinutes * 60;
  late int _remainingSeconds;
  bool _isRunning = false;
  bool _isFocusMode = true;
  bool _strictFocusEnabled = false;
  int _interruptions = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _focusDurationSeconds;
  }

  void _notifyLockState() {
    widget.onStrictFocusLockChanged
        ?.call(_strictFocusEnabled && _isRunning && _isFocusMode);
  }

  void _startOrPauseTimer() {
    if (_isRunning) {
      _timer?.cancel();

      if (_strictFocusEnabled && _isFocusMode) {
        _interruptions++;
      }

      setState(() {
        _isRunning = false;
      });

      _notifyLockState();
      return;
    }

    setState(() {
      _isRunning = true;
    });

    _notifyLockState();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_remainingSeconds == 0) {
        final bool completedFocusSession = _isFocusMode;

        timer.cancel();
        setState(() {
          _isRunning = false;
          _isFocusMode = !_isFocusMode;
            _remainingSeconds =
              _isFocusMode ? _focusDurationSeconds : _breakDurationSeconds;

          if (completedFocusSession) {
            _interruptions = 0;
          }
        });

        if (completedFocusSession) {
          widget.onFocusSessionCompleted?.call(_focusDurationSeconds ~/ 60);
        }

        _notifyLockState();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });
    });
  }

  void _resetTimer() {
    _timer?.cancel();

    if (_isRunning && _strictFocusEnabled && _isFocusMode) {
      _interruptions++;
    }

    setState(() {
      _isRunning = false;
      _isFocusMode = true;
      _remainingSeconds = _focusDurationSeconds;
      _interruptions = 0;
    });

    _notifyLockState();
  }

  String _formatTime(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    final String mm = minutes.toString().padLeft(2, '0');
    final String ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  Future<void> _openSetTimeDialog() async {
    final TextEditingController focusController = TextEditingController(
      text: (_focusDurationSeconds ~/ 60).toString(),
    );
    final TextEditingController breakController = TextEditingController(
      text: (_breakDurationSeconds ~/ 60).toString(),
    );

    final bool? shouldSave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Timer Length'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: focusController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Focus minutes (1-180)',
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              TextField(
                controller: breakController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Break minutes (1-60)',
                ),
              ),
            ],
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
      final int? focusMinutes = int.tryParse(focusController.text.trim());
      final int? breakMinutes = int.tryParse(breakController.text.trim());

      if (focusMinutes == null ||
          breakMinutes == null ||
          focusMinutes < 1 ||
          focusMinutes > 180 ||
          breakMinutes < 1 ||
          breakMinutes > 60) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Enter valid times. Focus: 1-180, Break: 1-60.'),
            ),
          );
        }
      } else {
        setState(() {
          _focusDurationSeconds = focusMinutes * 60;
          _breakDurationSeconds = breakMinutes * 60;
          _remainingSeconds = _isFocusMode
              ? _focusDurationSeconds
              : _breakDurationSeconds;
          _interruptions = 0;
        });
      }
    }

    focusController.dispose();
    breakController.dispose();
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.onStrictFocusLockChanged?.call(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _isFocusMode
      ? _remainingSeconds / _focusDurationSeconds
      : _remainingSeconds / _breakDurationSeconds;

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
              const SizedBox(height: AppSpacing.s12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s12,
                  vertical: AppSpacing.s12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.input,
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock_outlined, size: 20),
                    const SizedBox(width: AppSpacing.s8),
                    const Expanded(
                      child: Text(
                        'Strict Focus',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: _strictFocusEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _strictFocusEnabled = value;
                        });
                        _notifyLockState();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _strictFocusEnabled
                      ? 'Navigation lock is active while focus timer runs'
                      : 'Enable to lock navigation during focus sessions',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
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
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                  backgroundColor: AppColors.progressTrack,
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
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: AppSpacing.s8,
                          runSpacing: AppSpacing.s4,
                          children: [
                            Text(
                              'Pomodoro: ${_focusDurationSeconds ~/ 60} min focus • ${_breakDurationSeconds ~/ 60} min break',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _isRunning ? null : _openSetTimeDialog,
                              icon: const Icon(Icons.schedule_rounded, size: 16),
                              label: const Text('Set Time'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s12,
                            vertical: AppSpacing.s8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.small,
                            color: AppColors.background,
                          ),
                          child: Text(
                            'Interruptions: $_interruptions',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                            ],
                          ),
                        ),
                      );
                    },
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
                        backgroundColor: AppColors.buttonSecondary,
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
