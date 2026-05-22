import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static NotificationService? _instance;
  
  // Callback when user taps notification
  static void Function(String? taskId)? onNotificationTap;

  NotificationService._();

  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        onNotificationTap?.call(response.payload);
      },
    );

    _initialized = true;

    // Request notification permissions on Android 13+
    await requestPermissions();
  }

  static Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  static Future<void> showOverdueNotification(Task task, int minutesOverdue) async {
    final androidDetails = AndroidNotificationDetails(
      'overdue_channel',
      'Overdue Tasks',
      channelDescription: 'Repeating reminders for overdue tasks',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      ongoing: true,
      autoCancel: false,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction('complete', 'Complete'),
        const AndroidNotificationAction('snooze_10', 'Snooze 10min'),
        const AndroidNotificationAction('snooze_30', 'Snooze 30min'),
        const AndroidNotificationAction('snooze_60', 'Snooze 1hr'),
      ],
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: task.id.hashCode,
      title: '⏰ Overdue: ${task.title}',
      body: '$minutesOverdue ${minutesOverdue == 1 ? 'minute' : 'minutes'} overdue',
      notificationDetails: details,
      payload: task.id,
    );
  }

  static Future<void> showDueSoonNotification(Task task, int minutesBefore) async {
    final androidDetails = AndroidNotificationDetails(
      'due_soon_channel',
      'Due Soon',
      channelDescription: 'Reminders for tasks due soon',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: task.id.hashCode + 1000,
      title: '⏳ Due in $minutesBefore min: ${task.title}',
      body: 'Task is due soon',
      notificationDetails: details,
      payload: task.id,
    );
  }

  static Future<void> showReminderNotification(Task task) async {
    final androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Task Reminders',
      channelDescription: 'Exact task reminders',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: task.id.hashCode + 2000,
      title: '🔔 Reminder: ${task.title}',
      body: task.description.isNotEmpty ? task.description : 'Task reminder',
      notificationDetails: details,
      payload: task.id,
    );
  }

  static Future<void> showDailyDigest(
      int taskCount, String topPriority) async {
    final androidDetails = AndroidNotificationDetails(
      'digest_channel',
      'Daily Digest',
      channelDescription: 'Daily task summary',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: 3000,
      title: '☀️ Good morning!',
      body: 'You have $taskCount tasks today. Top priority: $topPriority',
      notificationDetails: details,
    );
  }

  static Future<void> showStreakMilestone(int streak) async {
    final androidDetails = AndroidNotificationDetails(
      'streak_channel',
      'Streak Milestones',
      channelDescription: 'Celebrate streak achievements',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: 4000,
      title: '🔥 Amazing! You\'ve hit a $streak-day streak!',
      body: 'Keep up the great work!',
      notificationDetails: details,
    );
  }

  static Future<void> showFocusComplete() async {
    final androidDetails = AndroidNotificationDetails(
      'focus_channel',
      'Focus Timer',
      channelDescription: 'Focus session notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      playSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true),
    );

    await _plugin.show(
      id: 5000,
      title: '⏰ Focus session complete!',
      body: 'Take a 5-min break 🌿',
      notificationDetails: details,
    );
  }

  static Future<void> cancelTaskNotifications(String taskId) async {
    await _plugin.cancel(id: taskId.hashCode);
    await _plugin.cancel(id: taskId.hashCode + 1000);
    await _plugin.cancel(id: taskId.hashCode + 2000);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> sendTestNotification() async {
    if (!_initialized) return;

    // Ensure permissions are granted before sending
    await requestPermissions();

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test',
      channelDescription: 'Test notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      id: 9999,
      title: '🔔 Test Notification',
      body: 'If you see this, notifications are working!',
      notificationDetails: details,
    );
  }

  static Future<void> showInAppBanner(BuildContext context, String title, String body,
      {Color? color, VoidCallback? onTap}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(ctx).padding.top + 8,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              entry.remove();
              onTap?.call();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A12).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color ?? const Color(0x3DFFFFFF),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (color ?? const Color(0xFF7C3AED)).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color ?? const Color(0xFF7C3AED),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (color ?? const Color(0xFF7C3AED)).withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          body,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => entry.remove(),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 5), () {
      if (entry.mounted) entry.remove();
    });

    return Future.value();
  }
}
