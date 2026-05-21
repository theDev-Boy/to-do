import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'priority_badge.dart';
import 'category_icon.dart';

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
    _animController.reverse().then((_) => widget.onDelete());
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
              widget.onSelectToggle?.call(true);
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
