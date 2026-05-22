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
import '../services/haptic_service.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  Future<void> _editReminder(BuildContext context, Task task) async {
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
    context.read<TaskProvider>().setReminder(task, reminderTime);
    HapticService.light();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final reminders = provider.tasksWithReminders;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Reminders'),
          ),
          body: reminders.isEmpty
              ? const EmptyState(
                  icon: Icons.alarm_outlined,
                  title: 'No reminders set',
                  subtitle: 'Long-press a task and tap "Set Reminder" to add one',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: reminders.length,
                  itemBuilder: (_, i) {
                    final task = reminders[i];
                    final reminderTime = task.reminderTime!;
                    final isOverdue = reminderTime.isBefore(DateTime.now());

                    return Dismissible(
                      key: ValueKey('reminder_${task.id}'),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentRed.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        child: const Icon(Icons.delete_outline, color: AppTheme.accentRed, size: 24),
                      ),
                      onDismissed: (_) {
                        HapticService.medium();
                        provider.clearReminder(task);
                      },
                      child: GlassCard(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(16),
                        radius: 16,
                        child: Row(
                          children: [
                            // Reminder time
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isOverdue
                                    ? AppTheme.accentRed.withValues(alpha: 0.12)
                                    : AppTheme.accentAmber.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isOverdue
                                      ? AppTheme.accentRed.withValues(alpha: 0.25)
                                      : AppTheme.accentAmber.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isOverdue ? Icons.warning_amber : Icons.alarm,
                                    size: 16,
                                    color: isOverdue ? AppTheme.accentRed : AppTheme.accentAmber,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('HH:mm').format(reminderTime),
                                    style: TextStyle(
                                      color: isOverdue ? AppTheme.accentRed : AppTheme.accentAmber,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Task info
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
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      CategoryIcon(index: task.categoryIndex, compact: true),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.schedule_outlined,
                                        size: 11,
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        DateFormat('MMM d, HH:mm').format(reminderTime),
                                        style: TextStyle(
                                          color: isOverdue ? AppTheme.accentRed : AppTheme.textSecondary,
                                          fontSize: 12,
                                          fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
                                        ),
                                      ),
                                      if (isOverdue) ...[
                                        const SizedBox(width: 6),
                                        const Text(
                                          'OVERDUE',
                                          style: TextStyle(
                                            color: AppTheme.accentRed,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Edit button
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.accentPrimary),
                              onPressed: () => _editReminder(context, task),
                              visualDensity: VisualDensity.compact,
                            ),
                            // Delete button - GestureDetector to avoid Dismissible interference
                            GestureDetector(
                              onTap: () {
                                HapticService.light();
                                provider.clearReminder(task);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: const Icon(Icons.close, size: 18, color: AppTheme.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
