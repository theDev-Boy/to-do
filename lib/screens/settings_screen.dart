import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/notification_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/haptic_service.dart';
import 'notification_settings_screen.dart';
import 'reminders_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TaskProvider, NotificationProvider>(
      builder: (context, provider, notifProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // App info
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.accentPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.accentPrimary.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(
                        Icons.checklist_rounded,
                        size: 32,
                        color: AppTheme.accentPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Finishly',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your premium task manager',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Notifications section
              const Text(
                'Preferences',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: notifProvider.notificationsEnabled
                    ? 'Enabled'
                    : 'Disabled',
                iconColor: notifProvider.notificationsEnabled
                    ? AppTheme.accentPrimary
                    : AppTheme.textSecondary,
                onTap: () {
                  HapticService.light();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 8),
              _SettingsTile(
                icon: Icons.alarm_outlined,
                title: 'Reminders',
                subtitle: '${context.read<TaskProvider>().tasksWithReminders.length} active',
                iconColor: AppTheme.accentAmber,
                onTap: () {
                  HapticService.light();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RemindersScreen()),
                  );
                },
              ),
              const SizedBox(height: 8),
              _SettingsTile(
                icon: Icons.vibration,
                title: 'Haptic Feedback',
                subtitle: notifProvider.hapticEnabled ? 'On' : 'Off',
                iconColor: notifProvider.hapticEnabled
                    ? AppTheme.accentPrimary
                    : AppTheme.textSecondary,
                onTap: () {
                  final newVal = !notifProvider.hapticEnabled;
                  notifProvider.setHapticEnabled(newVal);
                  HapticService.setEnabled(newVal);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(newVal ? 'Haptics enabled' : 'Haptics disabled'),
                      backgroundColor: const Color(0xFF0A0A12),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _SettingsTile(
                icon: Icons.volume_up_outlined,
                title: 'Sound Effects',
                subtitle: notifProvider.soundEnabled ? 'On' : 'Off',
                iconColor: notifProvider.soundEnabled
                    ? AppTheme.accentAmber
                    : AppTheme.textSecondary,
                onTap: () {
                  final newVal = !notifProvider.soundEnabled;
                  notifProvider.setSoundEnabled(newVal);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(newVal ? 'Sounds enabled' : 'Sounds disabled'),
                      backgroundColor: const Color(0xFF0A0A12),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Data section
              const Text(
                'Data',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.cleaning_services_outlined,
                title: 'Clear Completed Tasks',
                subtitle: 'Remove all completed tasks permanently',
                iconColor: AppTheme.accentGreen,
                onTap: () => _confirmClearCompleted(context, provider),
              ),
              const SizedBox(height: 8),
              _SettingsTile(
                icon: Icons.delete_forever_outlined,
                title: 'Delete All Tasks',
                subtitle: 'Remove all tasks from the database',
                iconColor: AppTheme.accentRed,
                onTap: () => _confirmDeleteAll(context, provider),
              ),
              const SizedBox(height: 24),

              // About section
              const Text(
                'About',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'Finishly v1.0.0',
                subtitle: 'Your premium task manager',
                iconColor: AppTheme.accentBlue,
                onTap: null,
              ),
              const SizedBox(height: 8),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy',
                subtitle: '100% offline. No data collection.',
                iconColor: AppTheme.accentGreen,
                onTap: null,
              ),
              const SizedBox(height: 8),
              _SettingsTile(
                icon: Icons.storage_outlined,
                title: 'Storage',
                subtitle: 'All data stored locally on your device',
                iconColor: AppTheme.accentAmber,
                onTap: null,
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  void _confirmClearCompleted(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgDark,
        title: const Text('Clear completed?', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'This will permanently remove all completed tasks.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearCompleted();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Completed tasks cleared')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgDark,
        title: const Text('Delete all?', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'This will permanently remove ALL tasks. This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteAll();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All tasks deleted')),
              );
            },
            child: const Text('Delete All', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      radius: 16,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
        ],
      ),
    );
  }
}
