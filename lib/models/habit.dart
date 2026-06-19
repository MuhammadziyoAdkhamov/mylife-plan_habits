import '../core/date_helper.dart';
import 'habit_completion.dart';
import 'habit_enums.dart';

class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.category,
    required this.frequency,
    required this.createdAt,
    required this.iconCodePoint,
    required this.xpReward,
    required this.completions,
    this.goal,
    this.reminder,
    this.isActive = true,
  });

  final String id;
  final String name;
  final HabitCategory category;
  final HabitFrequency frequency;
  final DateTime createdAt;
  final int iconCodePoint;
  final int xpReward;
  final List<HabitCompletion> completions;
  final String? goal;
  final String? reminder;
  final bool isActive;

  Habit copyWith({
    String? id,
    String? name,
    HabitCategory? category,
    HabitFrequency? frequency,
    DateTime? createdAt,
    int? iconCodePoint,
    int? xpReward,
    List<HabitCompletion>? completions,
    String? goal,
    String? reminder,
    bool? isActive,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt ?? this.createdAt,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      xpReward: xpReward ?? this.xpReward,
      completions: completions ?? this.completions,
      goal: goal ?? this.goal,
      reminder: reminder ?? this.reminder,
      isActive: isActive ?? this.isActive,
    );
  }

  bool isCompletedOn(DateTime date) {
    return completions.any((completion) => DateHelper.isSameDay(completion.date, date));
  }

  int get totalXp => completions.fold(0, (sum, item) => sum + item.xpEarned);

  int get completionCount => completions.length;

  int get currentStreak {
    if (completions.isEmpty) return 0;
    final keys = completions.map((e) => DateHelper.key(e.date)).toSet();
    var cursor = DateHelper.dateOnly(DateTime.now());
    if (!keys.contains(DateHelper.key(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (keys.contains(DateHelper.key(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get bestStreak {
    if (completions.isEmpty) return 0;
    final dates = completions.map((e) => DateHelper.dateOnly(e.date)).toList()..sort();
    var best = 1;
    var current = 1;
    for (var i = 1; i < dates.length; i++) {
      final diff = dates[i].difference(dates[i - 1]).inDays;
      if (diff == 1) {
        current++;
      } else if (diff > 1) {
        current = 1;
      }
      if (current > best) best = current;
    }
    return best;
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      category: enumFromString(HabitCategory.values, json['category'] as String?, HabitCategory.other),
      frequency: enumFromString(HabitFrequency.values, json['frequency'] as String?, HabitFrequency.everyday),
      createdAt: DateTime.parse(json['createdAt'] as String),
      iconCodePoint: json['iconCodePoint'] as int? ?? 0xe3af,
      xpReward: json['xpReward'] as int? ?? 40,
      completions: (json['completions'] as List<dynamic>? ?? [])
          .map((item) => HabitCompletion.fromJson(item as Map<String, dynamic>))
          .toList(),
      goal: json['goal'] as String?,
      reminder: json['reminder'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'frequency': frequency.name,
      'createdAt': createdAt.toIso8601String(),
      'iconCodePoint': iconCodePoint,
      'xpReward': xpReward,
      'completions': completions.map((item) => item.toJson()).toList(),
      'goal': goal,
      'reminder': reminder,
      'isActive': isActive,
    };
  }
}
