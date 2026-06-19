import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../providers/app_state.dart';
import '../widgets/app_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/stat_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final stats = app.stats;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          children: [
            const AppHeader(
              title: 'Profile',
              subtitle: 'Your growth identity',
            ),
            const SizedBox(height: 24),
            _ProfileAvatar(
              name: app.profile.name,
              avatarUrl: app.profile.avatarUrl,
            ),
            const SizedBox(height: 12),
            Text(
              app.profile.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              app.profile.email,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  app.isCloudUser
                      ? Icons.cloud_done_rounded
                      : Icons.phone_android_rounded,
                  size: 15,
                  color: app.isCloudUser ? AppColors.emerald : AppColors.gold,
                ),
                const SizedBox(width: 6),
                Text(
                  app.syncStatusLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Habits',
                    value: '${stats.totalHabits}',
                    color: AppColors.cyan,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'Days',
                    value: '${stats.bestStreak}',
                    color: AppColors.emerald,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'XP',
                    value: '${stats.totalXp}',
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Current Streak',
                    value: '${stats.currentStreak} Days',
                    color: AppColors.rose,
                    icon: Icons.local_fire_department_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'Longest Streak',
                    value: '${stats.bestStreak} Days',
                    color: AppColors.gold,
                    icon: Icons.emoji_events_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GlassCard(
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.person_outline_rounded,
                    title: 'Account',
                    onTap: () => context.go('/settings'),
                  ),
                  _SettingsRow(
                    icon: Icons.notifications_none_rounded,
                    title: 'Reminders',
                    onTap: () => context.go('/settings'),
                  ),
                  _SettingsRow(
                    icon: Icons.sync_rounded,
                    title: 'Data & Sync',
                    onTap: () => context.go('/settings'),
                  ),
                  _SettingsRow(
                    icon: Icons.palette_outlined,
                    title: 'Appearance',
                    onTap: () => context.go('/settings'),
                  ),
                  _SettingsRow(
                    icon: Icons.logout_rounded,
                    title: 'Sign out',
                    danger: true,
                    onTap: () async {
                      await context.read<AppState>().signOut();

                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.name,
    this.avatarUrl,
  });

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return CircleAvatar(
      radius: 44,
      backgroundColor: AppColors.surface3,
      backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
      child: hasAvatar
          ? null
          : Text(
              name.isEmpty ? '?' : name[0].toUpperCase(),
              style: Theme.of(context).textTheme.headlineLarge,
            ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.rose : AppColors.textSecondary;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color, size: 21),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: danger ? AppColors.rose : null,
            ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
      ),
      onTap: onTap,
    );
  }
}
