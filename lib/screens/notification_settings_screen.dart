import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/haptic_service.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Master toggle
              _SettingsSwitch(
                icon: Icons.notifications_outlined,
                title: 'Enable Notifications',
                subtitle: 'Master toggle for all notifications',
                value: provider.notificationsEnabled,
                onChanged: provider.setNotificationsEnabled,
                iconColor: AppTheme.accentPrimary,
              ),
              const SizedBox(height: 24),

              if (provider.notificationsEnabled) ...[
                // Overdue Repeater
                const Text(
                  'Overdue Reminders',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsSwitch(
                  icon: Icons.timer_outlined,
                  title: 'Overdue Minute Repeater',
                  subtitle: 'Repeats every ${provider.overdueIntervalMinutes} ${provider.overdueIntervalMinutes == 1 ? 'minute' : 'minutes'}',
                  value: provider.overdueRepeaterEnabled,
                  onChanged: provider.setOverdueRepeaterEnabled,
                  iconColor: AppTheme.accentRed,
                ),
                if (provider.overdueRepeaterEnabled) ...[
                  const SizedBox(height: 8),
                  _SettingsSlider(
                    title: 'Overdue Interval',
                    subtitle: '${provider.overdueIntervalMinutes} min',
                    value: provider.overdueIntervalMinutes.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    onChanged: (v) => provider.setOverdueIntervalMinutes(v.round()),
                  ),
                ],
                const SizedBox(height: 8),

                // Due Soon
                _SettingsSwitch(
                  icon: Icons.schedule_outlined,
                  title: 'Due Soon',
                  subtitle: 'Remind ${provider.dueSoonLeadMinutes} min before',
                  value: provider.dueSoonEnabled,
                  onChanged: provider.setDueSoonEnabled,
                  iconColor: AppTheme.accentAmber,
                ),
                if (provider.dueSoonEnabled) ...[
                  const SizedBox(height: 8),
                  _SettingsSlider(
                    title: 'Lead Time',
                    subtitle: '${provider.dueSoonLeadMinutes} min',
                    value: provider.dueSoonLeadMinutes.toDouble(),
                    min: 5,
                    max: 60,
                    divisions: 4,
                    onChanged: (v) => provider.setDueSoonLeadMinutes(v.round()),
                  ),
                ],
                const SizedBox(height: 8),

                // Reminders
                _SettingsSwitch(
                  icon: Icons.alarm_outlined,
                  title: 'Reminder Alarms',
                  subtitle: 'Exact reminder times',
                  value: provider.remindersEnabled,
                  onChanged: provider.setRemindersEnabled,
                  iconColor: AppTheme.accentBlue,
                ),
                const SizedBox(height: 24),

                // Digest section
                const Text(
                  'Daily & Streaks',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsSwitch(
                  icon: Icons.wb_sunny_outlined,
                  title: 'Daily Digest',
                  subtitle: 'At ${provider.dailyDigestTime}',
                  value: provider.dailyDigestEnabled,
                  onChanged: provider.setDailyDigestEnabled,
                  iconColor: AppTheme.accentAmber,
                ),
                const SizedBox(height: 8),
                _SettingsSwitch(
                  icon: Icons.local_fire_department_outlined,
                  title: 'Streak Milestones',
                  subtitle: 'Celebrate 7, 30, 100, 365 day streaks',
                  value: provider.streakMilestonesEnabled,
                  onChanged: provider.setStreakMilestonesEnabled,
                  iconColor: AppTheme.accentGreen,
                ),
                const SizedBox(height: 8),
                _SettingsSwitch(
                  icon: Icons.timer_off_outlined,
                  title: 'Focus Complete',
                  subtitle: 'When a Pomodoro session ends',
                  value: provider.focusCompleteEnabled,
                  onChanged: provider.setFocusCompleteEnabled,
                  iconColor: AppTheme.accentGreen,
                ),
                const SizedBox(height: 24),

                // Quiet hours
                const Text(
                  'Quiet Hours',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsSwitch(
                  icon: Icons.nightlight_round,
                  title: 'Quiet Hours',
                  subtitle: '${provider.quietHoursStart} - ${provider.quietHoursEnd}',
                  value: provider.quietHoursEnabled,
                  onChanged: provider.setQuietHoursEnabled,
                  iconColor: AppTheme.accentBlue,
                ),
                if (provider.quietHoursEnabled) ...[
                  const SizedBox(height: 8),
                  _SettingsSwitch(
                    icon: Icons.warning_amber_outlined,
                    title: 'Allow Critical Overdue',
                    subtitle: 'Override quiet hours for overdue tasks',
                    value: provider.quietHoursCriticalOverride,
                    onChanged: provider.setQuietHoursCriticalOverride,
                    iconColor: AppTheme.accentRed,
                  ),
                ],
                const SizedBox(height: 24),

                // Haptic & Sound
                const Text(
                  'Feedback',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsSwitch(
                  icon: Icons.vibration,
                  title: 'Haptic Feedback',
                  subtitle: 'Vibration on interactions',
                  value: provider.hapticEnabled,
                  onChanged: (v) {
                    provider.setHapticEnabled(v);
                    HapticService.setEnabled(v);
                  },
                  iconColor: AppTheme.accentPrimary,
                ),
                const SizedBox(height: 8),
                _SettingsSwitch(
                  icon: Icons.volume_up_outlined,
                  title: 'Sound Effects',
                  subtitle: 'Play sounds on interactions',
                  value: provider.soundEnabled,
                  onChanged: (v) {
                    provider.setSoundEnabled(v);
                  },
                  iconColor: AppTheme.accentAmber,
                ),
                const SizedBox(height: 8),
                _SettingsSwitch(
                  icon: Icons.badge_outlined,
                  title: 'App Icon Badge',
                  subtitle: 'Show overdue count on app icon',
                  value: provider.badgeEnabled,
                  onChanged: provider.setBadgeEnabled,
                  iconColor: AppTheme.accentRed,
                ),
                const SizedBox(height: 24),

                // Test
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  radius: 16,
                  onTap: () => provider.sendTestNotification(),
                  child: const Row(
                    children: [
                      Icon(Icons.send_outlined, color: AppTheme.accentPrimary, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Send Test Notification',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Permission status
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(16),
                radius: 16,
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: AppTheme.accentGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Notifications are enabled in system settings',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color iconColor;

  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      radius: 16,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: iconColor,
          ),
        ],
      ),
    );
  }
}

class _SettingsSlider extends StatelessWidget {
  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SettingsSlider({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      radius: 12,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.accentPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
