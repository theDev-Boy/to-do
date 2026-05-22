import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'priority_badge.dart';
import 'category_icon.dart';
import 'context_menu.dart';
import '../services/haptic_service.dart';
import '../providers/task_provider.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final bool isSelected;
  final bool selectMode;
  final VoidCallback? onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final ValueChanged<bool>? onSelectToggle;

  const TaskTile({
    super.key,
    required this.task,
    this.isSelected = false,
    this.selectMode = false,
    this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
    this.onSelectToggle,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  bool _isDeleted = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onDelete() {
    setState(() => _isDeleted = true);
    HapticService.heavy();
    _animController.reverse().then((_) => widget.onDelete());
  }

  void _showContextMenu(BuildContext context) {
    final pos = (context.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero) ?? Offset.zero;
    final task = widget.task;
    final provider = context.read<TaskProvider>();

    showContextMenu(
      context,
      position: pos,
      options: [
        ContextMenuOption(
          icon: Icons.content_copy,
          label: 'Duplicate',
          onTap: () {
            HapticService.light();
            provider.addTask(
              title: '[Copy] ${task.title}',
              description: task.description,
              priority: task.priority,
              dueDate: task.dueDate,
              categoryIndex: task.categoryIndex,
              tags: List.from(task.tags),
            );
          },
        ),
        ContextMenuOption(
          icon: Icons.flag_outlined,
          label: 'Change Priority',
          onTap: () => _showPriorityPicker(context, provider, task),
        ),
        ContextMenuOption(
          icon: Icons.alarm_add_outlined,
          label: 'Set Reminder',
          onTap: () => _showReminderPicker(context, provider, task),
        ),
        ContextMenuOption(
          icon: Icons.archive_outlined,
          label: task.isArchived ? 'Unarchive' : 'Archive',
          color: task.isArchived ? AppTheme.accentGreen : null,
          onTap: () {
            HapticService.medium();
            final updated = task.copyWith(isArchived: !task.isArchived);
            provider.updateTask(updated);
          },
          showDividerAbove: true,
        ),
        ContextMenuOption(
          icon: Icons.delete_outline,
          label: 'Delete',
          color: AppTheme.accentRed,
          onTap: () => _onDelete(),
        ),
      ],
    );
  }

  void _showReminderPicker(BuildContext context, TaskProvider provider, Task task) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: this.context,
      initialDate: task.reminderTime ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: this.context,
      initialTime: task.reminderTime != null
          ? TimeOfDay.fromDateTime(task.reminderTime!)
          : const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null || !mounted) return;

    final reminderTime = DateTime(
      date.year, date.month, date.day, time.hour, time.minute,
    );
    final updated = task.copyWith(reminderTime: reminderTime);
    provider.updateTask(updated);
    HapticService.light();
    if (!mounted) return;
    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(
        content: Text('Reminder set for ${DateFormat('MMM d, HH:mm').format(reminderTime)}'),
        backgroundColor: const Color(0xFF0A0A12),
      ),
    );
  }

  void _showPriorityPicker(BuildContext context, TaskProvider provider, Task task) {
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
            const Center(
              child: SizedBox(
                width: 40,
                height: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppTheme.textPlaceholder,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Change Priority',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(5, (i) {
              return ListTile(
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.priorityColor(i),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  i == 0 ? 'None' : AppTheme.priorityLabel(i),
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
                onTap: () {
                  final updated = task.copyWith(priority: i);
                  provider.updateTask(updated);
                  HapticService.light();
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isOverdue = task.isOverdue;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) => Transform.scale(
        scale: _isDeleted ? 0 : _scaleAnim.value,
        child: Opacity(
          opacity: _isDeleted ? 0 : _scaleAnim.value,
          child: child,
        ),
      ),
      child: Dismissible(
        key: ValueKey('${task.id}_${task.updatedAt.millisecondsSinceEpoch}'),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            widget.onToggleComplete();
            return false;
          }
          return true;
        },
        onDismissed: (_) => _onDelete(),
        background: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.accentGreen.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 24),
          child: const Icon(Icons.check_circle_outline, color: AppTheme.accentGreen, size: 28),
        ),
        secondaryBackground: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.accentRed.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Icon(Icons.delete_outline, color: AppTheme.accentRed, size: 28),
        ),
        child: GestureDetector(
          onTap: widget.selectMode
              ? () => widget.onSelectToggle?.call(!widget.isSelected)
              : widget.onTap,
          onLongPress: () {
            if (!widget.selectMode) {
              _showContextMenu(context);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppTheme.accentPrimary.withValues(alpha: 0.15)
                  : AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isSelected
                    ? AppTheme.accentPrimary.withValues(alpha: 0.4)
                    : AppTheme.borderLight,
              ),
            ),
            child: Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: widget.onToggleComplete,
                  child: Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? AppTheme.accentGreen.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.06),
                      border: Border.all(
                        color: task.isCompleted
                            ? AppTheme.accentGreen
                            : AppTheme.borderLight,
                        width: task.isCompleted ? 2 : 1.5,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check, size: 14, color: AppTheme.accentGreen)
                        : null,
                  ),
                ),
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
                              style: TextStyle(
                                color: task.isCompleted
                                    ? AppTheme.textSecondary
                                    : AppTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
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
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CategoryIcon(index: task.categoryIndex, compact: true),
                          const SizedBox(width: 12),
                          if (task.dueDate != null) ...[
                            Icon(
                              isOverdue ? Icons.flag : Icons.schedule_outlined,
                              size: 12,
                              color: isOverdue
                                  ? AppTheme.accentRed
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM d, HH:mm').format(task.dueDate!),
                              style: TextStyle(
                                color: isOverdue
                                    ? AppTheme.accentRed
                                    : AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ],
                          if (task.isArchived) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.archive_outlined,
                              size: 12,
                              color: AppTheme.accentAmber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Archived',
                              style: const TextStyle(
                                color: AppTheme.accentAmber,
                                fontSize: 11,
                              ),
                            ),
                          ],
                          if (task.reminderTime != null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.alarm_outlined,
                              size: 12,
                              color: AppTheme.accentAmber,
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
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              final updated = task.copyWith(isArchived: !task.isArchived);
                              context.read<TaskProvider>().updateTask(updated);
                              HapticService.light();
                            },
                            child: Icon(
                              Icons.archive_outlined,
                              size: 16,
                              color: task.isArchived ? AppTheme.accentAmber : AppTheme.textPlaceholder,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (widget.selectMode)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isSelected
                          ? AppTheme.accentPrimary
                          : Colors.transparent,
                      border: Border.all(
                        color: widget.isSelected
                            ? AppTheme.accentPrimary
                            : AppTheme.borderLight,
                        width: 2,
                      ),
                    ),
                    child: widget.isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
