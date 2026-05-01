import 'package:flutter/material.dart';

import '../services/journal_service.dart';
import '../theme/app_style.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({
    super.key,
    required this.completedToday,
    required this.totalTasks,
    required this.focusMinutesToday,
    required this.weeklyFocusMinutes,
    required this.weeklyCompletedTasks,
    required this.weeklyJournalEntries,
  });

  final int completedToday;
  final int totalTasks;
  final int focusMinutesToday;
  final List<int> weeklyFocusMinutes;
  final List<int> weeklyCompletedTasks;
  final List<JournalEntry> weeklyJournalEntries;

  @override
  Widget build(BuildContext context) {
    final double progress = totalTasks == 0 ? 0 : completedToday / totalTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Progress',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.card,
                border: Border.all(color: AppColors.divider),
                boxShadow: AppShadows.soft,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: progress.clamp(0, 1),
                          strokeWidth: 12,
                          backgroundColor: AppColors.progressTrack,
                          color: AppColors.accentGreen,
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(progress.clamp(0, 1) * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  const Text(
                    'You are building consistency one task at a time.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
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
                  const Text(
                    'Today\'s Stats',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Completed',
                          value: '$completedToday',
                          color: AppColors.accentGreen,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: _StatCard(
                          label: 'Total Tasks',
                          value: '$totalTasks',
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _StatCard(
                    label: 'Focus Minutes Today',
                    value: '$focusMinutesToday min',
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  ClipRRect(
                    borderRadius: AppRadius.small,
                    child: LinearProgressIndicator(
                      value: progress.clamp(0, 1),
                      minHeight: 8,
                      backgroundColor: AppColors.progressTrack,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            _WeeklyChartCard(
              title: '7-Day Task Completions',
              values: weeklyCompletedTasks,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.s12),
            _WeeklyChartCard(
              title: '7-Day Focus Minutes',
              values: weeklyFocusMinutes,
              color: AppColors.accentGreen,
            ),
            const SizedBox(height: AppSpacing.s12),
            _ReflectionSummaryCard(entries: weeklyJournalEntries),
          ],
        ),
      ),
    );
  }
}

class _ReflectionSummaryCard extends StatelessWidget {
  const _ReflectionSummaryCard({required this.entries});

  final List<JournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final int reflectionCount = entries.length;
    final JournalEntry? latest = entries.isEmpty ? null : entries.last;

    return Container(
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
            'Reflection Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            '$reflectionCount reflections in the last 7 days',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          if (latest != null) ...[
            const SizedBox(height: AppSpacing.s12),
            Text(
              'Latest win: ${latest.wentWell.isEmpty ? 'No note added' : latest.wentWell}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Latest blocker: ${latest.blockedBy.isEmpty ? 'No blocker added' : latest.blockedBy}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeeklyChartCard extends StatelessWidget {
  const _WeeklyChartCard({
    required this.title,
    required this.values,
    required this.color,
  });

  final String title;
  final List<int> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final int safeMax = values.isEmpty
        ? 1
        : values.reduce((int a, int b) => a > b ? a : b).clamp(1, 99999);

    return Container(
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          SizedBox(
            height: 86,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List<Widget>.generate(values.length, (int index) {
                final double ratio = values[index] / safeMax;
                final double barHeight = 12 + (56 * ratio.clamp(0, 1));

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${values[index]}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.input,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
