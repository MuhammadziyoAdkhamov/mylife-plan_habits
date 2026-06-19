import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../providers/app_state.dart';
import '../widgets/app_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_icon_button.dart';
import '../widgets/habit_tile.dart';
import '../widgets/progress_ring.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final stats = app.stats;
    final todayHabits = app.activeHabits;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            sliver: SliverToBoxAdapter(
              child: AppHeader(
                title: 'Good Morning, ${app.profile.name} 👋',
                subtitle: 'Let\'s make today amazing!',
                actionIcon: Icons.notifications_none_rounded,
                onAction: () {},
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: GlassCard(
                glowColor: AppColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today\'s Focus', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 18),
                    Center(
                      child: ProgressRing(
                        progress: stats.dailyProgress,
                        size: 142,
                        strokeWidth: 13,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${(stats.dailyProgress * 100).round()}%', style: Theme.of(context).textTheme.headlineLarge),
                            Text('Energy Score', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(child: StatCard(title: 'Habits', value: '${stats.completedToday}/${stats.totalHabits}', color: AppColors.cyan)),
                        const SizedBox(width: 10),
                        Expanded(child: StatCard(title: 'XP Earned', value: '${app.xpInCurrentLevel}', color: AppColors.emerald)),
                        const SizedBox(width: 10),
                        Expanded(child: StatCard(title: 'Streak', value: '🔥 ${stats.currentStreak}', color: AppColors.gold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(child: Text('Today\'s Habits', style: Theme.of(context).textTheme.titleLarge)),
                  TextButton(onPressed: () => context.go('/add-habit'), child: const Text('Add New')),
                ],
              ),
            ),
          ),
          if (todayHabits.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: EmptyState(
                  title: 'No habits yet',
                  message: 'Create your first habit and start building your life system.',
                  buttonText: 'Add Habit',
                  onButtonPressed: () => context.go('/add-habit'),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: todayHabits.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final habit = todayHabits[index];
                  final completed = habit.isCompletedOn(DateTime.now());
                  return HabitTile(
                    habit: habit,
                    completed: completed,
                    onToggle: () => context.read<AppState>().toggleHabitToday(habit.id),
                    onTap: () => context.go('/habit/${habit.id}'),
                  );
                },
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      onTap: () => context.go('/xp'),
                      child: Row(
                        children: [
                          const Icon(Icons.workspace_premium_rounded, color: AppColors.primary, size: 30),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Level ${app.level}', style: Theme.of(context).textTheme.titleMedium),
                                Text('${app.xpInCurrentLevel}/1000 XP', style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GlowIconButton(icon: Icons.add_rounded, onPressed: () => context.go('/add-habit')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
