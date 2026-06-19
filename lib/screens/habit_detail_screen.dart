import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/date_helper.dart';
import '../providers/app_state.dart';
import '../models/habit_enums.dart';
import '../widgets/app_header.dart';
import '../widgets/calendar_heatmap.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/premium_scaffold.dart';
import '../widgets/stat_card.dart';

class HabitDetailScreen extends StatelessWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final habit = app.habitById(habitId);
    if (habit == null) {
      return PremiumScaffold(
        body: Center(
          child: EmptyState(
            title: 'Habit not found',
            message: 'This habit does not exist anymore.',
            buttonText: 'Back Home',
            onButtonPressed: () => context.go('/home'),
          ),
        ),
      );
    }

    final color = AppColors.categoryColor(habit.category.label);
    final weekDays = DateHelper.lastDays(7);

    return PremiumScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            AppHeader(
              title: habit.name,
              subtitle: habit.category.label,
              leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded)),
            ),
            const SizedBox(height: 20),
            GlassCard(
              glowColor: color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: weekDays.map((day) {
                      final done = habit.isCompletedOn(day);
                      return Expanded(
                        child: Column(
                          children: [
                            Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][day.weekday - 1], style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 8),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: done ? AppColors.emerald : AppColors.surface3,
                                border: Border.all(color: done ? AppColors.emerald : AppColors.borderSoft),
                              ),
                              child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 17) : null,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: StatCard(title: 'Day Streak', value: '${habit.currentStreak}', subtitle: 'Best ${habit.bestStreak} days', color: AppColors.gold)),
                      const SizedBox(width: 12),
                      Expanded(child: StatCard(title: 'Total XP', value: '${habit.totalXp}', subtitle: 'Reward ${habit.xpReward}', color: AppColors.emerald)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monthly Heatmap', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 14),
                  CalendarHeatmap(values: _habitMonthHeatmap(app, habitId)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Habit Info', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Frequency', value: habit.frequency.label),
                  _InfoRow(label: 'Reminder', value: habit.reminder ?? 'Not set'),
                  _InfoRow(label: 'Goal', value: habit.goal ?? 'No goal'),
                  _InfoRow(label: 'Total completions', value: '${habit.completionCount}'),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Map<String, double> _habitMonthHeatmap(AppState app, String id) {
    final habit = app.habitById(id)!;
    final now = DateTime.now();
    final first = DateTime(now.year, now.month);
    final totalDays = DateTime(now.year, now.month + 1, 0).day;
    return {
      for (var i = 0; i < totalDays; i++)
        DateHelper.key(first.add(Duration(days: i))): habit.isCompletedOn(first.add(Duration(days: i))) ? 1 : 0,
    };
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
