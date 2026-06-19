import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../models/habit_enums.dart';
import '../providers/app_state.dart';
import '../widgets/app_header.dart';
import '../widgets/app_text_field.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/premium_scaffold.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen>
    with TickerProviderStateMixin {
  final nameController = TextEditingController();
  final reminderController = TextEditingController(text: '08:00 AM');
  final goalController = TextEditingController();

  late final AnimationController _introController;
  late final AnimationController _floatController;

  HabitCategory selectedCategory = HabitCategory.health;
  HabitFrequency selectedFrequency = HabitFrequency.everyday;

  bool trackHabit = true;
  bool _saving = false;
  int _selectedTemplateIndex = -1;

  final List<_HabitTemplate> _templates = const [
    _HabitTemplate(
      title: 'Suv ichish',
      goal: '8 glasses per day',
      reminder: '08:00 AM',
      categoryLabel: 'health',
      icon: Icons.water_drop_rounded,
    ),
    _HabitTemplate(
      title: 'Kitob o‘qish',
      goal: '20 minutes',
      reminder: '09:00 PM',
      categoryLabel: 'learning',
      icon: Icons.menu_book_rounded,
    ),
    _HabitTemplate(
      title: 'Dars qilish',
      goal: '2 hours focus',
      reminder: '10:00 AM',
      categoryLabel: 'learning',
      icon: Icons.school_rounded,
    ),
    _HabitTemplate(
      title: 'Mashq qilish',
      goal: '30 minutes',
      reminder: '07:00 AM',
      categoryLabel: 'fitness',
      icon: Icons.fitness_center_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _introController.dispose();
    _floatController.dispose();
    nameController.dispose();
    reminderController.dispose();
    goalController.dispose();
    super.dispose();
  }

  void _goBack() {
    HapticFeedback.selectionClick();

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  HabitCategory _categoryByLabel(String label) {
    final lower = label.toLowerCase();

    for (final category in HabitCategory.values) {
      if (category.label.toLowerCase().contains(lower)) {
        return category;
      }
    }

    return HabitCategory.health;
  }

  IconData _categoryIcon(HabitCategory category) {
    final label = category.label.toLowerCase();

    if (label.contains('health')) return Icons.favorite_rounded;
    if (label.contains('fitness')) return Icons.fitness_center_rounded;
    if (label.contains('learning')) return Icons.school_rounded;
    if (label.contains('mind')) return Icons.self_improvement_rounded;
    if (label.contains('product')) return Icons.rocket_launch_rounded;
    if (label.contains('work')) return Icons.work_rounded;
    if (label.contains('finance')) return Icons.savings_rounded;

    return Icons.auto_awesome_rounded;
  }

  Color _categoryColor(HabitCategory category) {
    return AppColors.categoryColor(category.label);
  }

  void _applyTemplate(int index) {
    final template = _templates[index];

    HapticFeedback.selectionClick();

    setState(() {
      _selectedTemplateIndex = index;
      nameController.text = template.title;
      goalController.text = template.goal;
      reminderController.text = template.reminder;
      selectedCategory = _categoryByLabel(template.categoryLabel);
      selectedFrequency = HabitFrequency.everyday;
      trackHabit = true;
    });
  }

  Future<void> _save() async {
    final name = nameController.text.trim();
    final reminder = reminderController.text.trim();
    final goal = goalController.text.trim();

    if (name.isEmpty) {
      HapticFeedback.mediumImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habit name required'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await context.read<AppState>().addHabit(
            name: name,
            category: selectedCategory,
            frequency: selectedFrequency,
            reminder: reminder.isEmpty ? null : reminder,
            goal: goal.isEmpty ? null : goal,
            isActive: trackHabit,
          );

      if (!mounted) return;

      HapticFeedback.heavyImpact();
      context.go('/home');
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habit qo‘shishda xatolik bo‘ldi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = _categoryColor(selectedCategory);

    return PremiumScaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = math.min(430.0, constraints.maxWidth);

            return Center(
              child: SizedBox(
                width: width,
                height: constraints.maxHeight,
                child: Stack(
                  children: [
                    _AnimatedAddHabitBackground(controller: _floatController),
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: const EdgeInsets.only(bottom: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          AppHeader(
                            title: 'Add New Habit',
                            subtitle: 'Build a small system for your future.',
                            leading: IconButton(
                              onPressed: _goBack,
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _IntroFadeSlide(
                            controller: _introController,
                            start: 0.00,
                            end: 0.42,
                            offsetY: 18,
                            child: _HabitPreviewHero(
                              selectedCategory: selectedCategory,
                              selectedColor: selectedColor,
                              habitName: nameController.text.trim(),
                              goal: goalController.text.trim(),
                              controller: _floatController,
                              icon: _categoryIcon(selectedCategory),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _IntroFadeSlide(
                            controller: _introController,
                            start: 0.10,
                            end: 0.58,
                            offsetY: 22,
                            child: GlassCard(
                              glowColor: selectedColor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _SectionTitle(
                                    title: 'Quick Templates',
                                    subtitle:
                                        'Start fast with a ready-made habit.',
                                  ),
                                  const SizedBox(height: 14),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _templates.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                      childAspectRatio: 1.34,
                                    ),
                                    itemBuilder: (context, index) {
                                      final template = _templates[index];

                                      return _TemplateCard(
                                        template: template,
                                        selected:
                                            _selectedTemplateIndex == index,
                                        onTap: () => _applyTemplate(index),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _IntroFadeSlide(
                            controller: _introController,
                            start: 0.20,
                            end: 0.70,
                            offsetY: 22,
                            child: GlassCard(
                              glowColor: AppColors.primary,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _SectionTitle(
                                    title: 'Habit Details',
                                    subtitle:
                                        'Make it clear, simple and trackable.',
                                  ),
                                  const SizedBox(height: 16),
                                  AppTextField(
                                    controller: nameController,
                                    hint: 'e.g. Drink Water',
                                    label: 'Habit Name',
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  const SizedBox(height: 14),
                                  AppTextField(
                                    controller: goalController,
                                    hint: 'e.g. 8 glasses / 20 minutes',
                                    label: 'Goal (Optional)',
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  const SizedBox(height: 14),
                                  AppTextField(
                                    controller: reminderController,
                                    hint: '08:00 AM',
                                    label: 'Reminder',
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _QuickReminderChip(
                                        label: 'No reminder',
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            reminderController.clear();
                                          });
                                        },
                                      ),
                                      _QuickReminderChip(
                                        label: '07:00 AM',
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            reminderController.text =
                                                '07:00 AM';
                                          });
                                        },
                                      ),
                                      _QuickReminderChip(
                                        label: '08:00 AM',
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            reminderController.text =
                                                '08:00 AM';
                                          });
                                        },
                                      ),
                                      _QuickReminderChip(
                                        label: '09:00 PM',
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            reminderController.text =
                                                '09:00 PM';
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _IntroFadeSlide(
                            controller: _introController,
                            start: 0.30,
                            end: 0.82,
                            offsetY: 22,
                            child: GlassCard(
                              glowColor: selectedColor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _SectionTitle(
                                    title: 'Category',
                                    subtitle:
                                        'Choose the area of life this habit improves.',
                                  ),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: HabitCategory.values.map(
                                      (category) {
                                        return _CategoryOption(
                                          label: category.label,
                                          icon: _categoryIcon(category),
                                          color: _categoryColor(category),
                                          selected:
                                              selectedCategory == category,
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            setState(() {
                                              selectedCategory = category;
                                            });
                                          },
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _IntroFadeSlide(
                            controller: _introController,
                            start: 0.40,
                            end: 0.92,
                            offsetY: 22,
                            child: GlassCard(
                              glowColor: AppColors.cyan,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _SectionTitle(
                                    title: 'Frequency',
                                    subtitle: 'How often do you want to do it?',
                                  ),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: HabitFrequency.values.map(
                                      (frequency) {
                                        return _FrequencyPill(
                                          label: frequency.label,
                                          selected:
                                              selectedFrequency == frequency,
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            setState(() {
                                              selectedFrequency = frequency;
                                            });
                                          },
                                        );
                                      },
                                    ).toList(),
                                  ),
                                  const SizedBox(height: 18),
                                  _TrackSwitchCard(
                                    value: trackHabit,
                                    onChanged: (value) {
                                      HapticFeedback.selectionClick();
                                      setState(() => trackHabit = value);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          _IntroFadeSlide(
                            controller: _introController,
                            start: 0.52,
                            end: 1.00,
                            offsetY: 16,
                            child: GradientButton(
                              text: _saving ? 'Saving...' : 'Save Habit',
                              icon: Icons.check_rounded,
                              enabled: !_saving,
                              onPressed: _saving ? null : _save,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HabitTemplate {
  const _HabitTemplate({
    required this.title,
    required this.goal,
    required this.reminder,
    required this.categoryLabel,
    required this.icon,
  });

  final String title;
  final String goal;
  final String reminder;
  final String categoryLabel;
  final IconData icon;
}

class _HabitPreviewHero extends StatelessWidget {
  const _HabitPreviewHero({
    required this.selectedCategory,
    required this.selectedColor,
    required this.habitName,
    required this.goal,
    required this.controller,
    required this.icon,
  });

  final HabitCategory selectedCategory;
  final Color selectedColor;
  final String habitName;
  final String goal;
  final AnimationController controller;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final title = habitName.isEmpty ? 'Your new habit' : habitName;
    final subtitle = goal.isEmpty ? selectedCategory.label : goal;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final floatY = math.sin(controller.value * math.pi) * 7;

        return Transform.translate(
          offset: Offset(0, -floatY),
          child: GlassCard(
            glowColor: selectedColor,
            borderColor: selectedColor.withOpacity(0.30),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        selectedColor,
                        AppColors.cyan,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: selectedColor.withOpacity(0.34),
                        blurRadius: 36,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preview',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TemplateCard extends StatefulWidget {
  const _TemplateCard({
    required this.template,
    required this.selected,
    required this.onTap,
  });

  final _HabitTemplate template;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hovered;
    final scale = _pressed
        ? 0.96
        : _hovered
            ? 1.02
            : 1.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.lightImpact();
          setState(() => _pressed = true);
        },
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          scale: scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary.withOpacity(0.14)
                  : AppColors.surface2.withOpacity(0.62),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active
                    ? AppColors.primary.withOpacity(0.50)
                    : AppColors.borderSoft.withOpacity(0.80),
              ),
              boxShadow: [
                if (active)
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  widget.template.icon,
                  color: active ? AppColors.primary : AppColors.textMuted,
                  size: 24,
                ),
                const Spacer(),
                Text(
                  widget.template.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.template.goal,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.16) : AppColors.surface2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? color.withOpacity(0.56) : AppColors.borderSoft,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: color.withOpacity(0.18),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : icon,
              color: selected ? color : AppColors.textMuted,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrequencyPill extends StatelessWidget {
  const _FrequencyPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.cyan.withOpacity(0.15)
              : AppColors.surface2.withOpacity(0.70),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.cyan.withOpacity(0.55)
                : AppColors.borderSoft,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check_rounded : Icons.repeat_rounded,
              color: selected ? AppColors.cyan : AppColors.textMuted,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: selected ? AppColors.cyan : AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickReminderChip extends StatelessWidget {
  const _QuickReminderChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor: AppColors.surface2.withOpacity(0.72),
      side: BorderSide(
        color: AppColors.borderSoft.withOpacity(0.82),
      ),
      label: Text(label),
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _TrackSwitchCard extends StatelessWidget {
  const _TrackSwitchCard({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: value
            ? AppColors.emerald.withOpacity(0.12)
            : AppColors.surface2.withOpacity(0.70),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: value
              ? AppColors.emerald.withOpacity(0.48)
              : AppColors.borderSoft,
        ),
      ),
      child: Row(
        children: [
          Icon(
            value ? Icons.track_changes_rounded : Icons.visibility_off_rounded,
            color: value ? AppColors.emerald : AppColors.textMuted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Track This Habit',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  value
                      ? 'It will appear on your home screen.'
                      : 'It will be saved but inactive.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColors.emerald,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
                height: 1.35,
              ),
        ),
      ],
    );
  }
}

class _AnimatedAddHabitBackground extends StatelessWidget {
  const _AnimatedAddHabitBackground({
    required this.controller,
  });

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final t = controller.value;

          return Stack(
            children: [
              Positioned(
                top: -100 + (t * 24),
                right: -110,
                child: const _Orb(
                  size: 240,
                  color: AppColors.primary,
                  opacity: 0.18,
                ),
              ),
              Positioned(
                top: 320 - (t * 18),
                left: -120,
                child: const _Orb(
                  size: 220,
                  color: AppColors.cyan,
                  opacity: 0.12,
                ),
              ),
              Positioned(
                bottom: -120 + (t * 22),
                right: -90,
                child: const _Orb(
                  size: 230,
                  color: AppColors.emerald,
                  opacity: 0.10,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(opacity),
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }
}

class _IntroFadeSlide extends StatelessWidget {
  const _IntroFadeSlide({
    required this.controller,
    required this.start,
    required this.end,
    required this.offsetY,
    required this.child,
  });

  final AnimationController controller;
  final double start;
  final double end;
  final double offsetY;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        start,
        end,
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final value = animation.value.clamp(0.0, 1.0).toDouble();

        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, offsetY * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}
