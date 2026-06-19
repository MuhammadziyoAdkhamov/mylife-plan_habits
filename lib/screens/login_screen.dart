import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../providers/app_state.dart';
import '../widgets/app_text_field.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/premium_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController(text: 'example@gmail.com');
  final passwordController = TextEditingController(text: 'password');

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    final app = context.read<AppState>();

    try {
      await app.signInWithGoogle();

      if (mounted) {
        context.go('/home');
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            app.errorMessage ?? 'Google orqali kirishda xatolik bo‘ldi.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showGoogleOnlyMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hozircha cloud sync uchun Google orqali kirish ishlaydi.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return PremiumScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.36),
                    blurRadius: 42,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome Back!',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Sign in to sync your life plan',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 34),
            GlassCard(
              child: Column(
                children: [
                  AppTextField(
                    controller: emailController,
                    hint: 'Email',
                    icon: Icons.mail_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: passwordController,
                    hint: 'Password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: true,
                  ),
                  const SizedBox(height: 18),
                  GradientButton(
                    text: app.isSyncing ? 'Connecting...' : 'Continue with Google',
                    icon: Icons.g_mobiledata_rounded,
                    onPressed: app.isSyncing ? null : _signInWithGoogle,
                  ),
                  if (app.isSyncing) ...[
                    const SizedBox(height: 14),
                    const LinearProgressIndicator(minHeight: 2),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'or continue with',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialButton(
                  label: 'G',
                  onTap: app.isSyncing ? null : _signInWithGoogle,
                ),
                const SizedBox(width: 14),
                _SocialButton(
                  icon: Icons.apple_rounded,
                  onTap: _showGoogleOnlyMessage,
                ),
                const SizedBox(width: 14),
                _SocialButton(
                  icon: Icons.email_outlined,
                  onTap: _showGoogleOnlyMessage,
                ),
              ],
            ),
            const SizedBox(height: 34),
            TextButton(
              onPressed: app.isSyncing ? null : _signInWithGoogle,
              child: const Text('Don\'t have an account? Sign Up with Google'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    this.label,
    this.icon,
    required this.onTap,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface.withOpacity(0.85),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, color: AppColors.textPrimary)
                : Text(
                    label!,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.cyan,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}
