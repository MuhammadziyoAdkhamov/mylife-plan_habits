import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../providers/app_state.dart';
import '../models/habit_enums.dart';
import '../widgets/app_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/mini_line_chart.dart';
import '../widgets/progress_ring.dart';
import '../widgets/stat_card.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final stats = app.stats;
    final weeklyValues = app.weeklyProgressMap.values.toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(title: 'Statistics', subtitle: 'Overview of your growth system'),
            const SizedBox(height: 20),
            GlassCard(
              glowColor: AppColors.emerald,
              child: Column(
                children: [
                  Row(
                    children: [
                      ProgressRing(
                        progress: stats.weeklyProgress,
                        size: 132,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${(stats.weeklyProgress * 100).round()}%', style: Theme.of(context).textTheme.headlineMedium),
                            Text('Overall', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('This Week', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 6),
                            Text('Your discipline score is calculated from daily habit completion.', style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: StatCard(title: 'Completed', value: '${stats.completedToday}', color: AppColors.emerald)),
                      const SizedBox(width: 10),
                      Expanded(child: StatCard(title: 'Missed', value: '${stats.missedThisWeek}', color: AppColors.rose)),
                      const SizedBox(width: 10),
                      Expanded(child: StatCard(title: 'Best Streak', value: '${stats.bestStreak}', color: AppColors.gold)),
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
                  Text('Progress', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  MiniLineChart(values: weeklyValues),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category Balance', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 14),
                  ...app.activeHabits.map((habit) {
                    final color = AppColors.categoryColor(habit.category.label);
                    final value = habit.completionCount / 30;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(habit.name, style: Theme.of(context).textTheme.labelLarge)),
                              Text('${(value.clamp(0, 1) * 100).round()}%', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                          const SizedBox(height: 7),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: value.clamp(0, 1),
                              minHeight: 8,
                              color: color,
                              backgroundColor: AppColors.surface3,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
