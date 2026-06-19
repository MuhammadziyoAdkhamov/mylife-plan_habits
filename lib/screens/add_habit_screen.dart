import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../models/habit_enums.dart';
import '../providers/app_state.dart';
import '../widgets/app_header.dart';
import '../widgets/app_text_field.dart';
import '../widgets/category_chip.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/premium_scaffold.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final nameController = TextEditingController();
  final reminderController = TextEditingController(text: '08:00 AM');
  final goalController = TextEditingController();
  HabitCategory selectedCategory = HabitCategory.health;
  HabitFrequency selectedFrequency = HabitFrequency.everyday;
  bool trackHabit = true;

  @override
  void dispose() {
    nameController.dispose();
    reminderController.dispose();
    goalController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Habit name required')));
      return;
    }
    await context.read<AppState>().addHabit(
          name: nameController.text,
          category: selectedCategory,
          frequency: selectedFrequency,
          reminder: reminderController.text,
          goal: goalController.text,
          isActive: trackHabit,
        );
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            AppHeader(
              title: 'Add New Habit',
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.14),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 44)],
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 46),
              ),
            ),
            const SizedBox(height: 24),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(controller: nameController, hint: 'e.g. Drink Water', label: 'Habit Name'),
                  const SizedBox(height: 18),
                  Text('Category', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: HabitCategory.values.map((category) {
                      return CategoryChip(
                        category: category,
                        selected: selectedCategory == category,
                        onTap: () => setState(() => selectedCategory = category),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<HabitFrequency>(
                    value: selectedFrequency,
                    dropdownColor: AppColors.surface,
                    decoration: const InputDecoration(labelText: 'Frequency'),
                    items: HabitFrequency.values
                        .map((frequency) => DropdownMenuItem(value: frequency, child: Text(frequency.label)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedFrequency = value ?? HabitFrequency.everyday),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(controller: reminderController, hint: '08:00 AM', label: 'Reminder'),
                  const SizedBox(height: 14),
                  AppTextField(controller: goalController, hint: 'e.g. 8 glasses / 2 hours', label: 'Goal (Optional)'),
                  const SizedBox(height: 14),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: trackHabit,
                    activeColor: AppColors.emerald,
                    title: Text('Track This Habit', style: Theme.of(context).textTheme.titleMedium),
                    onChanged: (value) => setState(() => trackHabit = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(text: 'Save Habit', icon: Icons.check_rounded, onPressed: _save),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
