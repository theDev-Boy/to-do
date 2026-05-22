import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_item.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  bool _notificationsEnabled = true;
  bool _overdueRepeaterEnabled = true;
  int _overdueIntervalMinutes = 1;
  bool _dueSoonEnabled = true;
  int _dueSoonLeadMinutes = 15;
  bool _remindersEnabled = true;
  bool _dailyDigestEnabled = true;
  String _dailyDigestTime = '08:00';
  bool _streakMilestonesEnabled = true;
  bool _focusCompleteEnabled = true;
  bool _quietHoursEnabled = false;
  String _quietHoursStart = '22:00';
  String _quietHoursEnd = '07:00';
  bool _quietHoursCriticalOverride = false;
  bool _weekendMode = false;
  bool _hapticEnabled = true;
  bool _soundEnabled = true;
  bool _badgeEnabled = true;
  bool _onboardingShown = false;
  int _unreadCount = 0;

  // Getters
  List<NotificationItem> get notifications => _notifications;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get overdueRepeaterEnabled => _overdueRepeaterEnabled;
  int get overdueIntervalMinutes => _overdueIntervalMinutes;
  bool get dueSoonEnabled => _dueSoonEnabled;
  int get dueSoonLeadMinutes => _dueSoonLeadMinutes;
  bool get remindersEnabled => _remindersEnabled;
  bool get dailyDigestEnabled => _dailyDigestEnabled;
  String get dailyDigestTime => _dailyDigestTime;
  bool get streakMilestonesEnabled => _streakMilestonesEnabled;
  bool get focusCompleteEnabled => _focusCompleteEnabled;
  bool get quietHoursEnabled => _quietHoursEnabled;
  String get quietHoursStart => _quietHoursStart;
  String get quietHoursEnd => _quietHoursEnd;
  bool get quietHoursCriticalOverride => _quietHoursCriticalOverride;
  bool get weekendMode => _weekendMode;
  bool get hapticEnabled => _hapticEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get badgeEnabled => _badgeEnabled;
  bool get onboardingShown => _onboardingShown;
  int get unreadCount => _unreadCount;
  List<NotificationItem> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  Future<void> initialize() async {
    await NotificationService.initialize();
    await _loadSettings();
    await _loadNotifications();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _overdueRepeaterEnabled = prefs.getBool('overdue_repeater') ?? true;
    _overdueIntervalMinutes = prefs.getInt('overdue_interval') ?? 1;
    _dueSoonEnabled = prefs.getBool('due_soon_enabled') ?? true;
    _dueSoonLeadMinutes = prefs.getInt('due_soon_lead') ?? 15;
    _remindersEnabled = prefs.getBool('reminders_enabled') ?? true;
    _dailyDigestEnabled = prefs.getBool('daily_digest_enabled') ?? true;
    _dailyDigestTime = prefs.getString('daily_digest_time') ?? '08:00';
    _streakMilestonesEnabled = prefs.getBool('streak_milestones') ?? true;
    _focusCompleteEnabled = prefs.getBool('focus_complete') ?? true;
    _quietHoursEnabled = prefs.getBool('quiet_hours') ?? false;
    _quietHoursStart = prefs.getString('quiet_hours_start') ?? '22:00';
    _quietHoursEnd = prefs.getString('quiet_hours_end') ?? '07:00';
    _quietHoursCriticalOverride = prefs.getBool('quiet_hours_override') ?? false;
    _weekendMode = prefs.getBool('weekend_mode') ?? false;
    _hapticEnabled = prefs.getBool('haptic_enabled') ?? true;
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _badgeEnabled = prefs.getBool('badge_enabled') ?? true;
    _onboardingShown = prefs.getBool('onboarding_shown') ?? false;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('overdue_repeater', _overdueRepeaterEnabled);
    await prefs.setInt('overdue_interval', _overdueIntervalMinutes);
    await prefs.setBool('due_soon_enabled', _dueSoonEnabled);
    await prefs.setInt('due_soon_lead', _dueSoonLeadMinutes);
    await prefs.setBool('reminders_enabled', _remindersEnabled);
    await prefs.setBool('daily_digest_enabled', _dailyDigestEnabled);
    await prefs.setString('daily_digest_time', _dailyDigestTime);
    await prefs.setBool('streak_milestones', _streakMilestonesEnabled);
    await prefs.setBool('focus_complete', _focusCompleteEnabled);
    await prefs.setBool('quiet_hours', _quietHoursEnabled);
    await prefs.setString('quiet_hours_start', _quietHoursStart);
    await prefs.setString('quiet_hours_end', _quietHoursEnd);
    await prefs.setBool('quiet_hours_override', _quietHoursCriticalOverride);
    await prefs.setBool('weekend_mode', _weekendMode);
    await prefs.setBool('haptic_enabled', _hapticEnabled);
    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setBool('badge_enabled', _badgeEnabled);
    await prefs.setBool('onboarding_shown', _onboardingShown);
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('notifications_data');
    if (data != null) {
      final list = jsonDecode(data) as List;
      _notifications = list
          .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    }
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_notifications.map((n) => n.toJson()).toList());
    await prefs.setString('notifications_data', data);
  }

  Future<void> addNotification(NotificationItem notification) async {
    _notifications.insert(0, notification);
    _unreadCount++;
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx >= 0 && !_notifications[idx].isRead) {
      _notifications[idx].isRead = true;
      _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
      await _saveNotifications();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    for (final n in _notifications) {
      n.isRead = true;
    }
    _unreadCount = 0;
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _notifications.clear();
    _unreadCount = 0;
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> removeNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    _unreadCount = _notifications.where((n) => !n.isRead).length;
    await _saveNotifications();
    notifyListeners();
  }

  // Settings setters
  Future<void> setNotificationsEnabled(bool v) async {
    _notificationsEnabled = v;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setOverdueRepeaterEnabled(bool v) async {
    _overdueRepeaterEnabled = v;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setOverdueIntervalMinutes(int v) async {
    _overdueIntervalMinutes = v;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setDueSoonEnabled(bool v) async {
    _dueSoonEnabled = v;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setDueSoonLeadMinutes(int v) async {
    _dueSoonLeadMinutes = v;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setRemindersEnabled(bool v) async {
    _remindersEnabled = v;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setDailyDigestEnabled(bool v) async {
    _dailyDigestEnabled = v;
    await _saveSettings();
    notifyListeners();
  }

  /// Validates and sets daily digest time. Must match HH:MM format.
  Future<void> setDailyDigestTime(String v) async {
    // Validate time format HH:MM
    if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(v)) return;
    _dailyDigestTime = v;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setStreakMilestonesEnabled(bool v) async {
    _streakMilestonesEnabled = v;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setFocusCompleteEnabled(bool v) async {
    _focusCompleteEnabled = v;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setQuietHoursEnabled(bool v) async {
    _quietHoursEnabled = v;
    await _saveSettings();
    notifyListeners();
  }

  /// Validates and sets quiet hours start time. Must match HH:MM format.
  Future<void> setQuietHoursStart(String v) async {
    if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(v)) return;
    _quietHoursStart = v;
    await _saveSettings();
    notifyListeners();
  }

  /// Validates and sets quiet hours end time. Must match HH:MM format.
  Future<void> setQuietHoursEnd(String v) async {
    if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(v)) return;
    _quietHoursEnd = v;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setQuietHoursCriticalOverride(bool v) async {
    _quietHoursCriticalOverride = v;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setHapticEnabled(bool v) async {
    _hapticEnabled = v;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool v) async {
    _soundEnabled = v;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setBadgeEnabled(bool v) async {
    _badgeEnabled = v;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setOnboardingShown(bool v) async {
    _onboardingShown = v;
    await _saveSettings();
    notifyListeners();
  }

  // Track last notification time per task to prevent over-firing
  final Map<String, DateTime> _lastOverdueNotification = {};

  // Check if task is overdue and fire notification
  Future<void> checkOverdueTask(Task task, List<Task> allTasks) async {
    if (!_notificationsEnabled || !_overdueRepeaterEnabled) return;
    if (task.isCompleted || task.dueDate == null) return;

    final now = DateTime.now();
    if (now.isAfter(task.dueDate!)) {
      final diff = now.difference(task.dueDate!);
      final minutes = diff.inMinutes;
      
      // Only fire if minutes >= 1 AND enough time has passed since last notification
      if (minutes >= 1) {
        final lastNotif = _lastOverdueNotification[task.id];
        final interval = Duration(minutes: _overdueIntervalMinutes);
        
        if (lastNotif == null || now.difference(lastNotif) >= interval) {
          // Check quiet hours
          if (_isInQuietHours(now) && !_quietHoursCriticalOverride) return;
          
          _lastOverdueNotification[task.id] = now;
          
          await NotificationService.showOverdueNotification(task, minutes);
          await addNotification(NotificationItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: '⏰ Overdue: ${task.title}',
            body: '$minutes ${minutes == 1 ? 'minute' : 'minutes'} overdue',
            taskId: task.id,
            type: NotificationType.overdue,
          ));
        }
      }
    }
  }

  // Run this periodically to check overdue tasks
  Future<void> checkAllOverdueTasks(List<Task> tasks) async {
    for (final task in tasks) {
      await checkOverdueTask(task, tasks);
    }
  }

  // Send a test notification using the initialized plugin
  Future<void> sendTestNotification() async {
    await NotificationService.sendTestNotification();
  }

  bool _isInQuietHours(DateTime now) {
    if (!_quietHoursEnabled) return false;

    final parts = _quietHoursStart.split(':');
    final startHour = int.parse(parts[0]);
    final startMin = int.parse(parts[1]);
    final parts2 = _quietHoursEnd.split(':');
    final endHour = int.parse(parts2[0]);
    final endMin = int.parse(parts2[1]);

    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = startHour * 60 + startMin;
    final endMinutes = endHour * 60 + endMin;

    if (startMinutes <= endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // Overnight quiet hours
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }
}
