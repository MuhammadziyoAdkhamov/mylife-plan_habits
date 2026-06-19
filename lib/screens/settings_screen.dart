import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../providers/app_state.dart';
import '../widgets/app_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/premium_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return PremiumScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            AppHeader(
              title: 'Settings',
              subtitle: 'Account, cloud sync and app preferences',
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const SizedBox(height: 20),
            _SettingsSection(
              title: 'Account',
              rows: [
                _SettingsStaticRow(
                  icon: Icons.person_outline_rounded,
                  title: 'Name',
                  subtitle: app.profile.name,
                ),
                _SettingsStaticRow(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: app.profile.email,
                ),
                _SettingsStaticRow(
                  icon: Icons.verified_user_outlined,
                  title: 'Login mode',
                  subtitle: app.isCloudUser
                      ? 'Google account connected'
                      : 'Local mode',
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SettingsSection(
              title: 'Cloud Sync',
              rows: [
                _SettingsStaticRow(
                  icon: Icons.cloud_done_outlined,
                  title: 'Status',
                  subtitle: app.syncStatusLabel,
                ),
                _SettingsStaticRow(
                  icon: Icons.storage_rounded,
                  title: 'Storage',
                  subtitle: app.isCloudUser
                      ? 'Firebase Firestore'
                      : 'Only this phone',
                ),
              ],
            ),
            if (app.errorMessage != null) ...[
              const SizedBox(height: 12),
              GlassCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.rose),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        app.errorMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.rose,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            const _SettingsSection(
              title: 'Reminders',
              rows: [
                _SettingsStaticRow(
                  icon: Icons.notifications_none_rounded,
                  title: 'Daily reminder',
                  subtitle: '08:00 AM',
                ),
                _SettingsStaticRow(
                  icon: Icons.nights_stay_outlined,
                  title: 'Evening review',
                  subtitle: '10:00 PM',
                ),
              ],
            ),
            const SizedBox(height: 14),
            const _SettingsSection(
              title: 'Appearance',
              rows: [
                _SettingsStaticRow(
                  icon: Icons.dark_mode_outlined,
                  title: 'Theme',
                  subtitle: 'Premium Dark',
                ),
                _SettingsStaticRow(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Glow effects',
                  subtitle: 'Enabled',
                ),
              ],
            ),
            const SizedBox(height: 20),
            GradientButton(
              text: app.isSyncing ? 'Syncing...' : 'Sync From Cloud',
              icon: Icons.sync_rounded,
              onPressed: app.isCloudUser && !app.isSyncing
                  ? () => context.read<AppState>().syncFromCloud()
                  : null,
            ),
            const SizedBox(height: 12),
            GradientButton(
              text: 'Reset Demo Data',
              icon: Icons.refresh_rounded,
              onPressed: () => context.read<AppState>().resetDemoData(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.rows,
  });

  final String title;
  final List<_SettingsStaticRow> rows;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }
}

class _SettingsStaticRow extends StatelessWidget {
  const _SettingsStaticRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
