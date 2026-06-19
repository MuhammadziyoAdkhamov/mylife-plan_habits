import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/date_helper.dart';
import '../models/app_badge.dart';
import '../models/app_stats.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../models/habit_enums.dart';
import '../models/journey_task.dart';
import '../models/user_profile.dart';
import '../models/xp_history_item.dart';
import '../services/auth_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/local_storage_service.dart';

class AppState extends ChangeNotifier {
  AppState({
    LocalStorageService? storage,
    AuthService? authService,
    CloudSyncService? cloudSyncService,
  })  : _storage = storage ?? LocalStorageService(),
        _auth = authService ?? AuthService(),
        _cloud = cloudSyncService ?? CloudSyncService();

  final LocalStorageService _storage;
  final AuthService _auth;
  final CloudSyncService _cloud;

  bool isLoading = true;
  bool isSyncing = false;
  bool onboardingCompleted = false;
  bool signedIn = false;
  String? errorMessage;
  DateTime? lastSyncedAt;

  UserProfile profile = UserProfile.demo();
  List<Habit> habits = [];
  List<AppBadge> badges = [];
  List<XPHistoryItem> xpHistory = [];
  List<JourneyTask> journeyTasks = [];

  bool get isCloudUser => _auth.currentUser != null;

  String get syncStatusLabel {
    if (isSyncing) return 'Syncing...';
    if (!isCloudUser) return 'Local mode';
    if (lastSyncedAt == null) return 'Cloud connected';
    return 'Cloud synced';
  }

  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final localData = await _storage.loadAppData();

      if (localData == null) {
        _loadDemoData();
        await _saveLocalOnly();
      } else {
        _restoreFromData(localData);
      }

      final firebaseUser = _auth.currentUser;
      signedIn = firebaseUser != null || signedIn;

      if (firebaseUser != null) {
        await _loadCloudOrCreate(firebaseUser);
      }

      _recalculateProfile();
      _refreshBadges();
    } catch (e) {
      errorMessage = _friendlyError(e);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    onboardingCompleted = true;
    await _saveAndNotify();
  }

  Future<void> signInWithGoogle() async {
    isSyncing = true;
    errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.signInWithGoogle();
      final user = credential.user;

      if (user == null) {
        throw StateError('Firebase user is null after Google sign-in.');
      }

      signedIn = true;
      onboardingCompleted = true;

      await _loadCloudOrCreate(user);
      await _saveLocalOnly();
    } catch (e) {
      errorMessage = _friendlyError(e);
      rethrow;
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> signIn({String? email}) async {
    signedIn = true;
    onboardingCompleted = true;

    if (email != null && email.trim().isNotEmpty) {
      profile = profile.copyWith(email: email.trim());
    }

    await _saveLocalOnly();
    notifyListeners();
  }

  Future<void> signOut() async {
    isSyncing = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _save();
      await _auth.signOut();
      signedIn = false;
      await _saveLocalOnly();
    } catch (e) {
      errorMessage = _friendlyError(e);
      rethrow;
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> syncFromCloud() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isSyncing = true;
    errorMessage = null;
    notifyListeners();

    try {
      final cloudData = await _cloud.loadAppData(user.uid);

      if (cloudData != null) {
        _restoreFromData(cloudData);
        signedIn = true;
        onboardingCompleted = true;
        profile = _profileFromFirebaseUser(user, fallback: profile);
        lastSyncedAt = DateTime.now();
        await _saveLocalOnly();
      }
    } catch (e) {
      errorMessage = _friendlyError(e);
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> resetDemoData() async {
    final user = _auth.currentUser;
    _loadDemoData();
    onboardingCompleted = true;
    signedIn = user != null;

    if (user != null) {
      profile = _profileFromFirebaseUser(user, fallback: profile);
    }

    await _saveAndNotify();
  }

  Future<void> addHabit({
    required String name,
    required HabitCategory category,
    required HabitFrequency frequency,
    required String? reminder,
    required String? goal,
    required bool isActive,
  }) async {
    final habit = Habit(
      id: _id('habit'),
      name: name.trim(),
      category: category,
      frequency: frequency,
      createdAt: DateTime.now(),
      iconCodePoint: _iconForCategory(category),
      xpReward: 40,
      completions: const [],
      goal: goal?.trim().isEmpty == true ? null : goal?.trim(),
      reminder: reminder?.trim().isEmpty == true ? null : reminder?.trim(),
      isActive: isActive,
    );

    habits = [habit, ...habits];
    await _saveAndNotify();
  }

  Future<void> toggleHabitToday(String habitId) async {
    final index = habits.indexWhere((habit) => habit.id == habitId);
    if (index == -1) return;

    final today = DateHelper.dateOnly(DateTime.now());
    final habit = habits[index];
    final alreadyDone = habit.isCompletedOn(today);
    final completions = [...habit.completions];

    if (alreadyDone) {
      completions.removeWhere(
        (completion) => DateHelper.isSameDay(completion.date, today),
      );

      xpHistory.removeWhere(
        (item) =>
            DateHelper.isSameDay(item.createdAt, today) &&
            (item.habitId == habitId || item.title == 'Perfect Day'),
      );
    } else {
      completions.add(HabitCompletion(date: today, xpEarned: habit.xpReward));

      xpHistory = [
        XPHistoryItem(
          id: _id('xp'),
          title: 'Completed Habit',
          subtitle: habit.name,
          amount: habit.xpReward,
          createdAt: DateTime.now(),
          habitId: habit.id,
        ),
        ...xpHistory,
      ];

      if (_isPerfectDay(today, overrideHabitId: habitId)) {
        xpHistory = [
          XPHistoryItem(
            id: _id('xp'),
            title: 'Perfect Day',
            subtitle: 'All daily habits completed',
            amount: 100,
            createdAt: DateTime.now(),
          ),
          ...xpHistory,
        ];
      }
    }

    habits[index] = habit.copyWith(completions: completions);
    _recalculateProfile();
    _refreshBadges();
    await _saveAndNotify();
  }

  Future<void> toggleJourneyTask(String taskId) async {
    final index = journeyTasks.indexWhere((task) => task.id == taskId);
    if (index == -1) return;

    final task = journeyTasks[index];
    if (task.isLocked) return;

    if (task.isCompleted) {
      journeyTasks[index] = task.copyWith(clearCompletedAt: true);
      xpHistory.removeWhere((item) => item.habitId == taskId);
    } else {
      journeyTasks[index] = task.copyWith(completedAt: DateTime.now());

      xpHistory = [
        XPHistoryItem(
          id: _id('xp'),
          title: 'Daily Journey',
          subtitle: 'Day ${task.day}: ${task.title}',
          amount: task.xpReward,
          createdAt: DateTime.now(),
          habitId: task.id,
        ),
        ...xpHistory,
      ];
    }

    _recalculateProfile();
    _refreshBadges();
    await _saveAndNotify();
  }

  Habit? habitById(String id) {
    try {
      return habits.firstWhere((habit) => habit.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Habit> get activeHabits {
    return habits.where((habit) => habit.isActive).toList();
  }

  int get completedTodayCount {
    final today = DateTime.now();
    return activeHabits.where((habit) => habit.isCompletedOn(today)).length;
  }

  double get dailyProgress {
    if (activeHabits.isEmpty) return 0;
    return completedTodayCount / activeHabits.length;
  }

  int get totalXp {
    return xpHistory.fold(0, (sum, item) => sum + item.amount);
  }

  int get level {
    return max(1, totalXp ~/ 1000 + 1);
  }

  int get xpInCurrentLevel {
    return totalXp % 1000;
  }

  double get levelProgress {
    return xpInCurrentLevel / 1000;
  }

  int get bestStreak {
    return habits.isEmpty ? 0 : habits.map((h) => h.bestStreak).reduce(max);
  }

  int get currentStreak {
    return habits.isEmpty ? 0 : habits.map((h) => h.currentStreak).reduce(max);
  }

  Map<String, double> get weeklyProgressMap {
    final days = DateHelper.lastDays(7);

    return {
      for (final day in days)
        DateHelper.key(day): activeHabits.isEmpty
            ? 0
            : activeHabits.where((habit) => habit.isCompletedOn(day)).length /
                activeHabits.length,
    };
  }

  Map<String, double> get monthHeatmap {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month);
    final totalDays = DateTime(now.year, now.month + 1, 0).day;

    return {
      for (var i = 0; i < totalDays; i++)
        DateHelper.key(first.add(Duration(days: i))): activeHabits.isEmpty
            ? 0
            : activeHabits
                    .where(
                      (habit) =>
                          habit.isCompletedOn(first.add(Duration(days: i))),
                    )
                    .length /
                activeHabits.length,
    };
  }

  AppStats get stats {
    final weekValues = weeklyProgressMap.values.toList();
    final weekly = weekValues.isEmpty
        ? 0.0
        : weekValues.reduce((a, b) => a + b) / weekValues.length;

    final monthValues = monthHeatmap.values.toList();
    final monthly = monthValues.isEmpty
        ? 0.0
        : monthValues.reduce((a, b) => a + b) / monthValues.length;

    final missed = weekValues.where((value) => value < 1).length;

    return AppStats(
      dailyProgress: dailyProgress,
      weeklyProgress: weekly,
      monthlyProgress: monthly,
      completedToday: completedTodayCount,
      totalHabits: activeHabits.length,
      missedThisWeek: missed,
      bestStreak: bestStreak,
      currentStreak: currentStreak,
      totalXp: totalXp,
      level: level,
    );
  }

  Future<void> _loadCloudOrCreate(User user) async {
    final cloudData = await _cloud.loadAppData(user.uid);

    if (cloudData == null) {
      signedIn = true;
      onboardingCompleted = true;
      profile = _profileFromFirebaseUser(user, fallback: profile);
      _recalculateProfile();
      _refreshBadges();
      await _cloud.saveAppData(user.uid, _toAppData());
    } else {
      _restoreFromData(cloudData);
      signedIn = true;
      onboardingCompleted = true;
      profile = _profileFromFirebaseUser(user, fallback: profile);
      _recalculateProfile();
      _refreshBadges();
      await _saveLocalOnly();
    }

    lastSyncedAt = DateTime.now();
  }

  UserProfile _profileFromFirebaseUser(
    User user, {
    required UserProfile fallback,
  }) {
    return fallback.copyWith(
      id: user.uid,
      name: (user.displayName == null || user.displayName!.trim().isEmpty)
          ? fallback.name
          : user.displayName!.trim(),
      email: (user.email == null || user.email!.trim().isEmpty)
          ? fallback.email
          : user.email!.trim(),
      avatarUrl: user.photoURL,
    );
  }

  void _restoreFromData(Map<String, dynamic> data) {
    onboardingCompleted = data['onboardingCompleted'] as bool? ?? false;
    signedIn = data['signedIn'] as bool? ?? false;

    final profileJson = data['profile'];
    profile = profileJson is Map
        ? UserProfile.fromJson(Map<String, dynamic>.from(profileJson))
        : UserProfile.demo();

    habits = (data['habits'] as List<dynamic>? ?? [])
        .map((item) => Habit.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    badges = (data['badges'] as List<dynamic>? ?? [])
        .map((item) => AppBadge.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    xpHistory = (data['xpHistory'] as List<dynamic>? ?? [])
        .map(
          (item) => XPHistoryItem.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();

    journeyTasks = (data['journeyTasks'] as List<dynamic>? ?? [])
        .map(
          (item) => JourneyTask.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();

    if (badges.isEmpty || journeyTasks.isEmpty) {
      final savedHabits = habits;
      final savedHistory = xpHistory;
      _loadDemoData();
      habits = savedHabits.isEmpty ? habits : savedHabits;
      xpHistory = savedHistory.isEmpty ? xpHistory : savedHistory;
    }
  }

  Map<String, dynamic> _toAppData() {
    return {
      'onboardingCompleted': onboardingCompleted,
      'signedIn': signedIn,
      'profile': profile.toJson(),
      'habits': habits.map((habit) => habit.toJson()).toList(),
      'badges': badges.map((badge) => badge.toJson()).toList(),
      'xpHistory': xpHistory.map((item) => item.toJson()).toList(),
      'journeyTasks': journeyTasks.map((task) => task.toJson()).toList(),
    };
  }

  bool _isPerfectDay(DateTime date, {String? overrideHabitId}) {
    if (activeHabits.isEmpty) return false;

    return activeHabits.every((habit) {
      if (habit.id == overrideHabitId) return true;
      return habit.isCompletedOn(date);
    });
  }

  void _recalculateProfile() {
    profile = profile.copyWith(totalXp: totalXp, level: level);
  }

  void _refreshBadges() {
    badges = badges.map((badge) {
      if (badge.isUnlocked) return badge;

      final unlocked = _badgeUnlocked(badge.id);

      return unlocked
          ? badge.copyWith(isUnlocked: true, unlockedAt: DateTime.now())
          : badge;
    }).toList();
  }

  bool _badgeUnlocked(String id) {
    switch (id) {
      case 'first_step':
        return habits.any((habit) => habit.completions.isNotEmpty);
      case 'seven_day_streak':
        return currentStreak >= 7;
      case 'focus_master':
        return journeyTasks.where((task) => task.isCompleted).length >= 10;
      case 'bookworm':
        return habits.any(
          (habit) =>
              habit.name.toLowerCase().contains('read') &&
              habit.completionCount >= 10,
        );
      case 'unstoppable':
        return totalXp >= 5000;
      case 'perfect_week':
        return weeklyProgressMap.values.every((value) => value >= 1) &&
            activeHabits.isNotEmpty;
      default:
        return false;
    }
  }

  int _iconForCategory(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return Icons.spa_rounded.codePoint;
      case HabitCategory.study:
        return Icons.menu_book_rounded.codePoint;
      case HabitCategory.mind:
        return Icons.psychology_rounded.codePoint;
      case HabitCategory.faith:
        return Icons.auto_awesome_rounded.codePoint;
      case HabitCategory.money:
        return Icons.savings_rounded.codePoint;
      case HabitCategory.other:
        return Icons.star_rounded.codePoint;
    }
  }

  String _id(String prefix) {
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9999)}';
  }

  Future<void> _saveAndNotify() async {
    await _save();
    notifyListeners();
  }

  Future<void> _saveLocalOnly() async {
    await _storage.saveAppData(_toAppData());
  }

  Future<void> _save() async {
    final data = _toAppData();
    await _storage.saveAppData(data);

    final user = _auth.currentUser;

    if (user != null && signedIn) {
      await _cloud.saveAppData(user.uid, data);
      lastSyncedAt = DateTime.now();
    }
  }

  String _friendlyError(Object error) {
    final text = error.toString();

    if (error is AuthCancelledException) {
      return 'Google login bekor qilindi.';
    }

    if (text.contains('network-request-failed')) {
      return 'Internet aloqasini tekshir.';
    }

    if (text.contains('ApiException: 10') ||
        text.contains('DEVELOPER_ERROR')) {
      return 'Google Auth sozlamasida SHA-1 yoki package name xato.';
    }

    if (text.contains('permission-denied')) {
      return 'Firestore rules ruxsat bermayapti.';
    }

    if (text.contains('REPLACE_WITH_FIREBASE')) {
      return 'Firebase hali ulanmagan. flutterfire configure qilish kerak.';
    }

    return text;
  }

  void _loadDemoData() {
    onboardingCompleted = false;
    signedIn = false;
    profile = UserProfile.demo();

    final now = DateTime.now();

    List<HabitCompletion> completionsFor(List<int> daysAgo, int xp) {
      return daysAgo
          .map(
            (d) => HabitCompletion(
              date: DateHelper.dateOnly(now.subtract(Duration(days: d))),
              xpEarned: xp,
            ),
          )
          .toList();
    }

    habits = [
      Habit(
        id: 'habit_morning_exercise',
        name: 'Morning Exercise',
        category: HabitCategory.health,
        frequency: HabitFrequency.everyday,
        createdAt: now.subtract(const Duration(days: 21)),
        iconCodePoint: Icons.spa_rounded.codePoint,
        xpReward: 40,
        completions: completionsFor(
          [0, 1, 2, 3, 4, 5, 6, 8, 9, 10, 12, 13],
          40,
        ),
        goal: '15 minutes',
        reminder: '06:30 AM',
      ),
      Habit(
        id: 'habit_study',
        name: 'Study 2 Hours',
        category: HabitCategory.study,
        frequency: HabitFrequency.everyday,
        createdAt: now.subtract(const Duration(days: 25)),
        iconCodePoint: Icons.menu_book_rounded.codePoint,
        xpReward: 50,
        completions: completionsFor(
          [0, 1, 2, 4, 5, 6, 9, 11, 12, 15],
          50,
        ),
        goal: '2 hours',
        reminder: '08:00 PM',
      ),
      Habit(
        id: 'habit_read',
        name: 'Read 20 Pages',
        category: HabitCategory.mind,
        frequency: HabitFrequency.everyday,
        createdAt: now.subtract(const Duration(days: 18)),
        iconCodePoint: Icons.auto_stories_rounded.codePoint,
        xpReward: 30,
        completions: completionsFor(
          [0, 1, 3, 4, 7, 8, 10, 14, 16],
          30,
        ),
        goal: '20 pages',
        reminder: '10:00 PM',
      ),
      Habit(
        id: 'habit_pray',
        name: 'Pray 5 Times',
        category: HabitCategory.faith,
        frequency: HabitFrequency.everyday,
        createdAt: now.subtract(const Duration(days: 30)),
        iconCodePoint: Icons.auto_awesome_rounded.codePoint,
        xpReward: 40,
        completions: completionsFor(
          [1, 2, 3, 4, 5, 7, 9, 10, 11],
          40,
        ),
        goal: '5 times',
        reminder: 'Every prayer time',
      ),
    ];

    xpHistory = [
      for (final habit in habits)
        for (final completion in habit.completions.take(8))
          XPHistoryItem(
            id: _id('xp'),
            title: 'Completed Habit',
            subtitle: habit.name,
            amount: completion.xpEarned,
            createdAt: completion.date,
            habitId: habit.id,
          ),
      XPHistoryItem(
        id: _id('xp'),
        title: 'Daily Bonus',
        subtitle: 'Consistency reward',
        amount: 20,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    badges = const [
      AppBadge(
        id: 'first_step',
        title: 'First Step',
        description: 'Complete 1 habit',
        iconCodePoint: 0xe838,
        requiredValue: 1,
      ),
      AppBadge(
        id: 'seven_day_streak',
        title: '7 Day Streak',
        description: '7 days in row',
        iconCodePoint: 0xef55,
        requiredValue: 7,
      ),
      AppBadge(
        id: 'focus_master',
        title: 'Focus Master',
        description: '10 journey days',
        iconCodePoint: 0xe8d0,
        requiredValue: 10,
      ),
      AppBadge(
        id: 'bookworm',
        title: 'Bookworm',
        description: 'Read 10 days',
        iconCodePoint: 0xe865,
        requiredValue: 10,
      ),
      AppBadge(
        id: 'unstoppable',
        title: 'Unstoppable',
        description: 'Earn 5000 XP',
        iconCodePoint: 0xe3af,
        requiredValue: 5000,
      ),
      AppBadge(
        id: 'perfect_week',
        title: 'Perfect Week',
        description: 'All habits for 7 days',
        iconCodePoint: 0xe885,
        requiredValue: 7,
      ),
    ];

    final journeyTitles = [
      'Wake up early',
      'No phone in morning',
      'Study 2 hours',
      'Read 20 pages',
      'Sleep before 11 PM',
      'Write daily reflection',
      'Clean your room',
      'Walk 20 minutes',
      'Plan tomorrow',
      'Deep work session',
    ];

    journeyTasks = List.generate(30, (index) {
      final day = index + 1;

      return JourneyTask(
        id: 'journey_$day',
        day: day,
        title: journeyTitles[index % journeyTitles.length],
        description: 'Small focused action for day $day.',
        xpReward: 25,
        completedAt: day <= 2 ? now.subtract(Duration(days: 3 - day)) : null,
        isLocked: day > 7,
      );
    });

    _recalculateProfile();
    _refreshBadges();
  }
}
