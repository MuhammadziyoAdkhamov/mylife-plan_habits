import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/date_helper.dart';
import '../models/habit_enums.dart';
import '../providers/app_state.dart';
import '../widgets/app_header.dart';
import '../widgets/calendar_heatmap.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/premium_scaffold.dart';
import '../widgets/stat_card.dart';

class HabitDetailScreen extends StatelessWidget {
  const HabitDetailScreen({
    super.key,
    required this.habitId,
  });

  final String habitId;

  void _goBack(BuildContext context) {
    HapticFeedback.selectionClick();

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  Future<void> _confirmDeleteHabit(
    BuildContext context,
    String habitId,
    String habitName,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Habitni o‘chiraymi?'),
          content: Text(
            '"$habitName" butunlay o‘chadi. Bu amalni ortga qaytarib bo‘lmaydi.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Bekor qilish'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'O‘chirish',
                style: TextStyle(color: AppColors.rose),
              ),
            ),
          ],
        );
      },
    );

    if (result == true && context.mounted) {
      HapticFeedback.mediumImpact();

      await context.read<AppState>().deleteHabit(habitId);

      if (context.mounted) {
        context.go('/home');
      }
    }
  }

  Future<void> _confirmUndoToday(
    BuildContext context,
    String habitId,
    String habitName,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Bajarilganni bekor qilaymi?'),
          content: Text(
            '"$habitName" bugun bajarilgan deb belgilangan. Uni bajarilmagan holatga qaytaraymi?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Yo‘q'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Ha, qaytar'),
            ),
          ],
        );
      },
    );

    if (result == true && context.mounted) {
      HapticFeedback.lightImpact();
      await context.read<AppState>().toggleHabitToday(habitId);
    }
  }

  Map<String, double> _habitMonthHeatmap(AppState app, String id) {
    final habit = app.habitById(id)!;
    final now = DateTime.now();
    final first = DateTime(now.year, now.month);
    final totalDays = DateTime(now.year, now.month + 1, 0).day;

    return {
      for (var i = 0; i < totalDays; i++)
        DateHelper.key(first.add(Duration(days: i))):
            habit.isCompletedOn(first.add(Duration(days: i))) ? 1 : 0,
    };
  }

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
    final completedToday = habit.isCompletedOn(DateTime.now());

    return PremiumScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              AppHeader(
                title: habit.name,
                subtitle: habit.category.label,
                leading: IconButton(
                  onPressed: () => _goBack(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                actionIcon: Icons.delete_outline_rounded,
                onAction: () => _confirmDeleteHabit(
                  context,
                  habit.id,
                  habit.name,
                ),
              ),
              const SizedBox(height: 20),
              _TodayStatusCard(
                habitName: habit.name,
                color: color,
                completedToday: completedToday,
                xpReward: habit.xpReward,
                onToggle: () {
                  if (completedToday) {
                    _confirmUndoToday(context, habit.id, habit.name);
                    return;
                  }

                  HapticFeedback.lightImpact();
                  context.read<AppState>().toggleHabitToday(habit.id);
                },
              ),
              const SizedBox(height: 18),
              GlassCard(
                glowColor: completedToday ? AppColors.emerald : color,
                borderColor:
                    completedToday ? AppColors.emerald.withOpacity(0.52) : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last 7 Days',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: weekDays.map((day) {
                        final done = habit.isCompletedOn(day);

                        return Expanded(
                          child: _WeekDayDot(
                            label: [
                              'M',
                              'T',
                              'W',
                              'T',
                              'F',
                              'S',
                              'S',
                            ][day.weekday - 1],
                            done: done,
                            color: color,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Day Streak',
                            value: '${habit.currentStreak}',
                            subtitle: 'Best ${habit.bestStreak} days',
                            color: AppColors.gold,
                            icon: Icons.local_fire_department_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Total XP',
                            value: '${habit.totalXp}',
                            subtitle: 'Reward ${habit.xpReward}',
                            color: AppColors.emerald,
                            icon: Icons.bolt_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GlassCard(
                glowColor: AppColors.cyan,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Heatmap',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your consistency map for this month.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                    const SizedBox(height: 14),
                    CalendarHeatmap(
                      values: _habitMonthHeatmap(app, habitId),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GlassCard(
                glowColor: color,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Habit Info',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 14),
                    _InfoRow(
                      label: 'Frequency',
                      value: habit.frequency.label,
                    ),
                    _InfoRow(
                      label: 'Reminder',
                      value: habit.reminder ?? 'Not set',
                    ),
                    _InfoRow(
                      label: 'Goal',
                      value: habit.goal ?? 'No goal',
                    ),
                    _InfoRow(
                      label: 'Total completions',
                      value: '${habit.completionCount}',
                    ),
                    _InfoRow(
                      label: 'Created',
                      value: DateHelper.key(habit.createdAt),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _DangerDeleteCard(
                habitName: habit.name,
                onDelete: () => _confirmDeleteHabit(
                  context,
                  habit.id,
                  habit.name,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayStatusCard extends StatelessWidget {
  const _TodayStatusCard({
    required this.habitName,
    required this.color,
    required this.completedToday,
    required this.xpReward,
    required this.onToggle,
  });

  final String habitName;
  final Color color;
  final bool completedToday;
  final int xpReward;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onToggle,
      glowColor: completedToday ? AppColors.emerald : color,
      borderColor: completedToday ? AppColors.emerald.withOpacity(0.58) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: completedToday
                    ? const LinearGradient(
                        colors: [
                          AppColors.emerald,
                          AppColors.cyan,
                        ],
                      )
                    : AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: (completedToday ? AppColors.emerald : color)
                        .withOpacity(0.30),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(
                completedToday ? Icons.check_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    completedToday ? 'Completed today' : 'Not completed today',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: completedToday
                              ? AppColors.emerald
                              : AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    completedToday
                        ? 'Tap to undo after confirmation.'
                        : 'Tap to complete and earn $xpReward XP.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              completedToday
                  ? Icons.undo_rounded
                  : Icons.check_circle_outline_rounded,
              color: completedToday ? AppColors.emerald : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekDayDot extends StatelessWidget {
  const _WeekDayDot({
    required this.label,
    required this.done,
    required this.color,
  });

  final String label;
  final bool done;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          width: done ? 32 : 28,
          height: done ? 32 : 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? AppColors.emerald : AppColors.surface3,
            border: Border.all(
              color: done ? AppColors.emerald : AppColors.borderSoft,
            ),
            boxShadow: done
                ? [
                    BoxShadow(
                      color: AppColors.emerald.withOpacity(0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: done
              ? const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18,
                )
              : Icon(
                  Icons.circle_outlined,
                  color: color.withOpacity(0.55),
                  size: 14,
                ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface2.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderSoft.withOpacity(0.78),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerDeleteCard extends StatelessWidget {
  const _DangerDeleteCard({
    required this.habitName,
    required this.onDelete,
  });

  final String habitName;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: AppColors.rose,
      borderColor: AppColors.rose.withOpacity(0.32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danger Zone',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.rose,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Delete "$habitName" if you no longer need this habit.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.rose,
              ),
              label: const Text(
                'Delete Habit',
                style: TextStyle(
                  color: AppColors.rose,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.rose.withOpacity(0.55),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
