import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../services/haptic_service.dart';
import '../services/sound_service.dart';
import 'confetti_overlay.dart';
import 'undo_toast.dart';

class BulkActionBar extends StatefulWidget {
  const BulkActionBar({super.key});

  @override
  State<BulkActionBar> createState() => _BulkActionBarState();
}

class _BulkActionBarState extends State<BulkActionBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_slideController);
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        if (!provider.isSelectMode || provider.selectedIds.isEmpty) {
          return const SizedBox.shrink();
        }

        final count = provider.selectedIds.length;

        return SlideTransition(
          position: _slideAnim,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A12).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Count indicator
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.borderLight,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$count selected',
                        style: const TextStyle(
                          color: AppTheme.accentPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Actions grid
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ActionChip(
                          icon: Icons.checklist,
                          label: 'Complete',
                          color: AppTheme.accentGreen,
                          onTap: () {
                            HapticService.medium();
                            SoundService.playBulkAction();
                            provider.completeSelected().then((_) {
                              if (mounted) showMinorConfetti(context);
                            });
                          },
                        ),
                        _ActionChip(
                          icon: Icons.delete_outline,
                          label: 'Delete',
                          color: AppTheme.accentRed,
                          onTap: () {
                            HapticService.heavy();
                            final taskNames = provider.selectedIds
                                .map((id) => provider.tasks
                                    .firstWhere((t) => t.id == id)
                                    .title)
                                .take(3)
                                .toList();
                            final deletedIds = Set<String>.from(provider.selectedIds);

                            provider.deleteSelected().then((_) {
                              if (!mounted) return;
                              showUndoToast(
                                context,
                                message: 'Deleted ${deletedIds.length} tasks',
                                description: taskNames.join(', '),
                                onUndo: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Undo is not yet implemented'),
                                      backgroundColor: const Color(0xFF0A0A12),
                                    ),
                                  );
                                },
                              );
                            });
                          },
                        ),
                        _ActionChip(
                          icon: Icons.content_copy,
                          label: 'Duplicate',
                          color: AppTheme.accentBlue,
                          onTap: () {
                            HapticService.medium();
                            for (final id in provider.selectedIds) {
                              final task = provider.tasks.firstWhere(
                                (t) => t.id == id,
                                orElse: () => provider.tasks.first,
                              );
                              if (task.id == id) {
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
                              }
                            }
                            provider.cancelSelectMode();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Duplicated ${provider.selectedIds.length} tasks'),
                                backgroundColor: const Color(0xFF0A0A12),
                              ),
                            );
                          },
                        ),
                        _ActionChip(
                          icon: Icons.drive_file_move_outline,
                          label: 'Move',
                          color: AppTheme.accentAmber,
                          onTap: () => _showCategoryPicker(context, provider),
                        ),
                        _ActionChip(
                          icon: Icons.flag_outlined,
                          label: 'Priority',
                          color: AppTheme.accentRed,
                          onTap: () => _showPriorityPicker(context, provider),
                        ),
                        _ActionChip(
                          icon: Icons.calendar_today,
                          label: 'Due Date',
                          color: AppTheme.accentBlue,
                          onTap: () => _showDatePicker(context, provider),
                        ),
                        _ActionChip(
                          icon: Icons.label_outline,
                          label: 'Add Tag',
                          color: AppTheme.priorityMedium,
                          onTap: () => _showTagPicker(context, provider),
                        ),
                        _ActionChip(
                          icon: Icons.file_upload_outlined,
                          label: 'Export',
                          color: AppTheme.accentGreen,
                          onTap: () {
                            HapticService.light();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Exporting selected tasks...'),
                                backgroundColor: const Color(0xFF0A0A12),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCategoryPicker(BuildContext context, TaskProvider provider) {
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
              'Move to Category',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(AppTheme.categoryNames.length, (i) {
              return ListTile(
                leading: Icon(
                  Icons.folder_outlined,
                  color: AppTheme.categoryColors[i],
                  size: 22,
                ),
                title: Text(
                  AppTheme.categoryNames[i],
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
                onTap: () {
                  for (final id in provider.selectedIds) {
                    final idx = provider.tasks.indexWhere((t) => t.id == id);
                    if (idx >= 0) {
                      final updated = provider.tasks[idx].copyWith(categoryIndex: i);
                      provider.updateTask(updated);
                    }
                  }
                  provider.cancelSelectMode();
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

  void _showPriorityPicker(BuildContext context, TaskProvider provider) {
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
                  for (final id in provider.selectedIds) {
                    final idx = provider.tasks.indexWhere((t) => t.id == id);
                    if (idx >= 0) {
                      final updated = provider.tasks[idx].copyWith(priority: i);
                      provider.updateTask(updated);
                    }
                  }
                  provider.cancelSelectMode();
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

  void _showDatePicker(BuildContext context, TaskProvider provider) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 23, minute: 59),
    );
    if (time == null || !mounted) return;

    final dueDate = DateTime(
      date.year, date.month, date.day, time.hour, time.minute,
    );

    for (final id in provider.selectedIds) {
      final idx = provider.tasks.indexWhere((t) => t.id == id);
      if (idx >= 0) {
        final updated = provider.tasks[idx].copyWith(dueDate: dueDate);
        provider.updateTask(updated);
      }
    }
    provider.cancelSelectMode();
  }

  void _showTagPicker(BuildContext context, TaskProvider provider) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A12),
        title: const Text('Add Tag', style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Enter tag name',
            hintStyle: TextStyle(color: AppTheme.textPlaceholder),
          ),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) {
              for (final id in provider.selectedIds) {
                final idx = provider.tasks.indexWhere((t) => t.id == id);
                if (idx >= 0) {
                  final tags = List<String>.from(provider.tasks[idx].tags);
                  if (!tags.contains(v.trim().toLowerCase())) {
                    tags.add(v.trim().toLowerCase());
                  }
                  final updated = provider.tasks[idx].copyWith(tags: tags);
                  provider.updateTask(updated);
                }
              }
              provider.cancelSelectMode();
              Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final v = ctrl.text.trim();
              if (v.isNotEmpty) {
                for (final id in provider.selectedIds) {
                  final idx = provider.tasks.indexWhere((t) => t.id == id);
                  if (idx >= 0) {
                    final tags = List<String>.from(provider.tasks[idx].tags);
                    if (!tags.contains(v.toLowerCase())) {
                      tags.add(v.toLowerCase());
                    }
                    final updated = provider.tasks[idx].copyWith(tags: tags);
                    provider.updateTask(updated);
                  }
                }
                provider.cancelSelectMode();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: widget.color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
