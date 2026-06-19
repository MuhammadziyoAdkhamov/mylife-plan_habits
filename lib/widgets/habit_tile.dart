import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../models/habit.dart';
import '../models/habit_enums.dart';
import 'glass_card.dart';

class HabitTile extends StatelessWidget {
  const HabitTile({
    super.key,
    required this.habit,
    required this.completed,
    required this.onToggle,
    required this.onTap,
  });

  final Habit habit;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(habit.category.label);
    return AnimatedScale(
      duration: const Duration(milliseconds: 170),
      scale: completed ? 0.99 : 1,
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderColor: completed ? color.withOpacity(0.35) : null,
        glowColor: completed ? color : null,
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: color.withOpacity(0.16),
              ),
              child: Icon(IconData(habit.iconCodePoint, fontFamily: 'MaterialIcons'), color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(habit.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(habit.category.label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed ? AppColors.emerald : Colors.transparent,
                  border: Border.all(color: completed ? AppColors.emerald : AppColors.border),
                ),
                child: completed ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
