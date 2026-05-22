import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/priority_badge.dart';
import '../widgets/category_icon.dart';
import '../widgets/task_create_sheet.dart';
import '../services/haptic_service.dart';

class ArchivedTasksScreen extends StatelessWidget {
  const ArchivedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final archivedTasks = provider.archivedTasks;

        return Scaffold(
          appBar: AppBar(
            title: Text('Archived (${archivedTasks.length})'),
          ),
          body: archivedTasks.isEmpty
              ? const EmptyState(
                  icon: Icons.archive_outlined,
                  title: 'No archived tasks',
                  subtitle: 'Archive tasks from the Tasks screen to see them here',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: archivedTasks.length,
                  itemBuilder: (_, i) {
                    final task = archivedTasks[i];
                    return _ArchivedTaskTile(task: task);
                  },
                ),
        );
      },
    );
  }
}

class _ArchivedTaskTile extends StatelessWidget {
  final Task task;

  const _ArchivedTaskTile({required this.task});

  void _showContextMenu(BuildContext context) {
    final provider = context.read<TaskProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A12),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppTheme.borderLight)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textPlaceholder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              task.title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Archived task',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            // Unarchive
            _ActionItem(
              icon: Icons.unarchive_outlined,
              label: 'Unarchive',
              color: AppTheme.accentGreen,
              onTap: () {
                HapticService.light();
                provider.unarchiveTask(task);
                Navigator.pop(ctx);
              },
            ),
            // Edit
            _ActionItem(
              icon: Icons.edit_outlined,
              label: 'Edit',
              color: AppTheme.accentPrimary,
              onTap: () {
                HapticService.light();
                Navigator.pop(ctx);
                TaskCreateSheet.show(context, task: task);
              },
            ),
            // Duplicate
            _ActionItem(
              icon: Icons.content_copy,
              label: 'Duplicate',
              color: AppTheme.accentBlue,
              onTap: () {
                HapticService.light();
                provider.addTask(
                  title: '[Copy] ${task.title}',
                  description: task.description,
                  priority: task.priority,
                  dueDate: task.dueDate,
                  categoryIndex: task.categoryIndex,
                  tags: List.from(task.tags),
                  subtasks: task.subtasks.map((s) => SubTask(
                    id: DateTime.now().microsecondsSinceEpoch.toString() + s.id,
                    title: s.title,
                  )).toList(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Task duplicated'),
                    backgroundColor: AppTheme.snackbarBg,
                  ),
                );
              },
            ),
            // Set / Unset Reminder
            if (task.reminderTime != null)
              _ActionItem(
                icon: Icons.alarm_off_outlined,
                label: 'Unset Reminder',
                color: AppTheme.accentRed,
                onTap: () {
                  HapticService.medium();
                  provider.clearReminder(task);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Reminder removed'),
                      backgroundColor: AppTheme.snackbarBg,
                    ),
                  );
                },
              )
            else
              _ActionItem(
                icon: Icons.alarm_add_outlined,
                label: 'Set Reminder',
                color: AppTheme.accentAmber,
                onTap: () {
                  Navigator.pop(ctx);
                  _showReminderPicker(context, provider, task);
                },
              ),
            const Divider(height: 1, color: AppTheme.borderLight),
            // Delete
            _ActionItem(
              icon: Icons.delete_forever_outlined,
              label: 'Delete Permanently',
              color: AppTheme.accentRed,
              onTap: () {
                HapticService.heavy();
                Navigator.pop(ctx);
                _confirmDelete(context, provider, task);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderPicker(BuildContext context, TaskProvider provider, Task task) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: task.reminderTime ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || context.mounted == false) return;

    final time = await showTimePicker(
      context: context,
      initialTime: task.reminderTime != null
          ? TimeOfDay.fromDateTime(task.reminderTime!)
          : const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null || context.mounted == false) return;

    final reminderTime = DateTime(
      date.year, date.month, date.day, time.hour, time.minute,
    );
    if (!context.mounted) return;
    provider.setReminder(task, reminderTime);
    HapticService.light();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder set for ${DateFormat('MMM d, HH:mm').format(reminderTime)}'),
        backgroundColor: AppTheme.snackbarBg,
      ),
    );
  }

  void _confirmDelete(BuildContext context, TaskProvider provider, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgDark,
        title: const Text('Delete permanently?', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Delete "${task.title}"? This cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTask(task.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      radius: 16,
      onTap: () => _showContextMenu(context),
      child: Row(
        children: [
          // Archived icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.accentAmber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.25)),
            ),
            child: const Icon(
              Icons.archive_outlined,
              size: 20,
              color: AppTheme.accentAmber,
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (task.priority > 0) ...[
                      const SizedBox(width: 8),
                      PriorityBadge(priority: task.priority, compact: true),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    CategoryIcon(index: task.categoryIndex, compact: true),
                    const SizedBox(width: 12),
                    if (task.dueDate != null) ...[
                      Icon(
                        Icons.schedule_outlined,
                        size: 12,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, HH:mm').format(task.dueDate!),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    if (task.reminderTime != null) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.alarm,
                        size: 12,
                        color: AppTheme.accentAmber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Set',
                        style: const TextStyle(
                          color: AppTheme.accentAmber,
                          fontSize: 11,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(width: 12),
                      Text(
                        'Not set',
                        style: const TextStyle(
                          color: AppTheme.textPlaceholder,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    if (task.subtasks.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.checklist_outlined,
                        size: 12,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${task.subtasks.where((s) => s.isCompleted).length}/${task.subtasks.length}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            size: 18,
            color: AppTheme.textPlaceholder,
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
