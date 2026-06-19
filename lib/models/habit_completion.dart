class HabitCompletion {
  const HabitCompletion({
    required this.date,
    required this.xpEarned,
  });

  final DateTime date;
  final int xpEarned;

  HabitCompletion copyWith({DateTime? date, int? xpEarned}) {
    return HabitCompletion(
      date: date ?? this.date,
      xpEarned: xpEarned ?? this.xpEarned,
    );
  }

  factory HabitCompletion.fromJson(Map<String, dynamic> json) {
    return HabitCompletion(
      date: DateTime.parse(json['date'] as String),
      xpEarned: json['xpEarned'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'xpEarned': xpEarned,
    };
  }
}
