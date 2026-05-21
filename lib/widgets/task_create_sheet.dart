import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import 'category_icon.dart';

class TaskCreateSheet extends StatefulWidget {
  final Task? task;

  const TaskCreateSheet({super.key, this.task});

  @override
  State<TaskCreateSheet> createState() => _TaskCreateSheetState();

  static Future<void> show(BuildContext context, {Task? task}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => TaskCreateSheet(task: task),
    );
  }
}

class _TaskCreateSheetState extends State<TaskCreateSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _tagCtrl;
  int _priority = 0;
  int _categoryIndex = 0;
  DateTime? _dueDate;
  List<String> _tags = [];
  List<SubTask> _subtasks = [];
  bool _isSaving = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _tagCtrl = TextEditingController();
    _priority = t?.priority ?? 0;
    _categoryIndex = t?.categoryIndex ?? 0;
    _dueDate = t?.dueDate;
    _tags = t?.tags ?? [];
    _subtasks = t?.subtasks ?? [];
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    setState(() => _isSaving = true);

    final provider = context.read<TaskProvider>();

    if (_isEditing) {
      final updated = widget.task!.copyWith(
        title: title,
        description: _descCtrl.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        categoryIndex: _categoryIndex,
        tags: List.from(_tags),
        subtasks: List.from(_subtasks),
      );
      await provider.updateTask(updated);
    } else {
      await provider.addTask(
        title: title,
        description: _descCtrl.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        categoryIndex: _categoryIndex,
        tags: List.from(_tags),
        subtasks: List.from(_subtasks),
      );
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _dueDate != null
          ? TimeOfDay.fromDateTime(_dueDate!)
          : const TimeOfDay(hour: 23, minute: 59),
    );
    if (time == null || !mounted) return;

    setState(() {
      _dueDate = DateTime(
        date.year, date.month, date.day, time.hour, time.minute,
      );
    });
  }

  void _addTag() {
    final tag = _tagCtrl.text.trim().toLowerCase();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
      _tagCtrl.clear();
    }
  }

  void _addSubtask() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgDark,
        title: const Text('Add Subtask', style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Subtask title'),
          style: const TextStyle(color: AppTheme.textPrimary),
          onSubmitted: (_) {
            final text = ctrl.text.trim();
            if (text.isNotEmpty) {
              setState(() {
                _subtasks.add(SubTask(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: text,
                ));
              });
            }
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final text = ctrl.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _subtasks.add(SubTask(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: text,
                  ));
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppTheme.borderLight),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textPlaceholder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditing ? 'Edit Task' : 'New Task',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: _titleCtrl.text.trim().isEmpty
                            ? AppTheme.accentPrimary.withValues(alpha: 0.3)
                            : AppTheme.accentPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton(
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'Save',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Scrollable form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextField(
                    controller: _titleCtrl,
                    autofocus: !_isEditing,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'What needs to be done?',
                      filled: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  // Description
                  TextField(
                    controller: _descCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Add description...',
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Priority
                  const Text('Priority', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) {
                      final active = _priority == i;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _priority = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppTheme.priorityColor(i).withValues(alpha: 0.2)
                                  : AppTheme.bgCard,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: active
                                    ? AppTheme.priorityColor(i).withValues(alpha: 0.5)
                                    : AppTheme.borderLight,
                              ),
                            ),
                            child: Text(
                              i == 0 ? 'None' : AppTheme.priorityLabel(i),
                              style: TextStyle(
                                color: active ? AppTheme.priorityColor(i) : AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Category
                  const Text('Category', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: AppTheme.categoryNames.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final active = _categoryIndex == i;
                        return GestureDetector(
                          onTap: () => setState(() => _categoryIndex = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppTheme.categoryColors[i].withValues(alpha: 0.2)
                                  : AppTheme.bgCard,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: active
                                    ? AppTheme.categoryColors[i].withValues(alpha: 0.5)
                                    : AppTheme.borderLight,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CategoryIcon.icons[i],
                                  size: 14,
                                  color: active ? AppTheme.categoryColors[i] : AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  AppTheme.categoryNames[i],
                                  style: TextStyle(
                                    color: active ? AppTheme.categoryColors[i] : AppTheme.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Due date
                  const Text('Due Date', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _dueDate != null ? Icons.calendar_today : Icons.calendar_today_outlined,
                            size: 16,
                            color: _dueDate != null ? AppTheme.accentPrimary : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _dueDate != null
                                  ? DateFormat('EEEE, MMM d, yyyy • HH:mm').format(_dueDate!)
                                  : 'Set due date & time',
                              style: TextStyle(
                                color: _dueDate != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (_dueDate != null)
                            GestureDetector(
                              onTap: () => setState(() => _dueDate = null),
                              child: const Icon(Icons.close, size: 18, color: AppTheme.textSecondary),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tags
                  const Text('Tags', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_tags.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _tags.map((tag) => Chip(
                              label: Text(tag, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
                              deleteIcon: const Icon(Icons.close, size: 14, color: AppTheme.textSecondary),
                              onDeleted: () => setState(() => _tags.remove(tag)),
                              backgroundColor: AppTheme.accentPrimary.withValues(alpha: 0.12),
                              side: BorderSide(color: AppTheme.accentPrimary.withValues(alpha: 0.25)),
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            )).toList(),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _tagCtrl,
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: 'Add tag...',
                                  border: InputBorder.none,
                                  filled: false,
                                  isDense: true,
                                ),
                                onSubmitted: (_) => _addTag(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 20, color: AppTheme.accentPrimary),
                              onPressed: _addTag,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Subtasks
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtasks', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                      TextButton.icon(
                        onPressed: _addSubtask,
                        icon: const Icon(Icons.add, size: 16, color: AppTheme.accentPrimary),
                        label: const Text('Add', style: TextStyle(color: AppTheme.accentPrimary, fontSize: 13)),
                      ),
                    ],
                  ),
                  if (_subtasks.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: const Center(
                        child: Text(
                          'No subtasks yet',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_subtasks.length, (i) {
                      final sub = _subtasks[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _subtasks[i] = SubTask(
                                    id: sub.id,
                                    title: sub.title,
                                    isCompleted: !sub.isCompleted,
                                  );
                                });
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: sub.isCompleted
                                      ? AppTheme.accentGreen.withValues(alpha: 0.2)
                                      : Colors.white.withValues(alpha: 0.06),
                                  border: Border.all(
                                    color: sub.isCompleted ? AppTheme.accentGreen : AppTheme.borderLight,
                                    width: sub.isCompleted ? 2 : 1.5,
                                  ),
                                ),
                                child: sub.isCompleted
                                    ? const Icon(Icons.check, size: 12, color: AppTheme.accentGreen)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                sub.title,
                                style: TextStyle(
                                  color: sub.isCompleted ? AppTheme.textSecondary : AppTheme.textPrimary,
                                  fontSize: 14,
                                  decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _subtasks.removeAt(i)),
                              child: const Icon(Icons.close, size: 16, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
