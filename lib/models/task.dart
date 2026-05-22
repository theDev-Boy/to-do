class SubTask {
  final String id;
  String title;
  bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted ? 1 : 0,
      };

  factory SubTask.fromJson(Map<String, dynamic> json) => SubTask(
        id: json['id'] as String,
        title: json['title'] as String,
        isCompleted: (json['isCompleted'] as int) == 1,
      );
}

class Task {
  final String id;
  String title;
  String description;
  int priority; // 0=None, 1=Low, 2=Medium, 3=High, 4=Critical
  DateTime? dueDate;
  int categoryIndex;
  List<String> tags;
  List<SubTask> subtasks;
  bool isCompleted;
  DateTime createdAt;
  DateTime updatedAt;
  bool isInProgress;
  int focusSessions;
  bool isArchived;
  DateTime? reminderTime;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = 0,
    this.dueDate,
    this.categoryIndex = 0,
    List<String>? tags,
    List<SubTask>? subtasks,
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isInProgress = false,
    this.focusSessions = 0,
    this.isArchived = false,
    this.reminderTime,
  })  : tags = tags ?? [],
        subtasks = subtasks ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get subtaskProgress {
    if (subtasks.isEmpty) return 0;
    final done = subtasks.where((s) => s.isCompleted).length;
    return done / subtasks.length;
  }

  bool get isOverdue =>
      dueDate != null && !isCompleted && dueDate!.isBefore(DateTime.now());

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isDueThisWeek {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));
    return dueDate!.isAfter(now) && dueDate!.isBefore(weekEnd);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'priority': priority,
        'dueDate': dueDate?.millisecondsSinceEpoch,
        'categoryIndex': categoryIndex,
        'tags': _encodeTags(tags),
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
        'isCompleted': isCompleted ? 1 : 0,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
        'isInProgress': isInProgress ? 1 : 0,
        'focusSessions': focusSessions,
        'isArchived': isArchived ? 1 : 0,
        'reminderTime': reminderTime?.millisecondsSinceEpoch,
      };

  /// Securely encode tags list using a delimiter unlikely in user input.
  static String _encodeTags(List<String> tags) {
    return tags.join('|||');
  }

  /// Securely decode tags string, handling malformed or null data gracefully.
  static List<String> _decodeTags(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      return raw.split('|||').where((t) => t.trim().isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }

    static DateTime? parseSafeDateTime(dynamic value) {
      if (value is int && value > 0) {
        if (value < -2208988800000 || value > 4102444800000) return null;
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return null;
    }

  factory Task.fromJson(Map<String, dynamic> json) {
    // Safe deserialization with type guards against malformed data
    final id = (json['id'] as String?) ?? '';
    final title = (json['title'] as String?) ?? '';
    final description = (json['description'] as String?) ?? '';
    final priority = (json['priority'] as int?) ?? 0;
    final categoryIndex = (json['categoryIndex'] as int?) ?? 0;
    final isCompleted = (json['isCompleted'] as int?) == 1;
    final isInProgress = (json['isInProgress'] as int?) == 1;
    final focusSessions = (json['focusSessions'] as int?) ?? 0;
    final isArchived = (json['isArchived'] as int?) == 1;
    final reminderTime = parseSafeDateTime(json['reminderTime']);

    final dueDate = parseSafeDateTime(json['dueDate']);
    final createdAt = parseSafeDateTime(json['createdAt']) ?? DateTime.now();
    final updatedAt = parseSafeDateTime(json['updatedAt']) ?? DateTime.now();

    // Parse tags with secure decoder
    final tags = _decodeTags(json['tags'] as String?);

    // Parse subtasks with type guards
    List<SubTask> subtasks = [];
    final rawSubtasks = json['subtasks'];
    if (rawSubtasks is List) {
      subtasks = rawSubtasks
          .whereType<Map<String, dynamic>>()
          .map((m) {
            final subId = (m['id'] as String?) ?? '';
            final subTitle = (m['title'] as String?) ?? '';
            final subCompleted = (m['isCompleted'] as int?) == 1;
            return SubTask(id: subId, title: subTitle, isCompleted: subCompleted);
          })
          .toList();
    }

    return Task(
      id: id,
      title: title,
      description: description,
      priority: priority.clamp(0, 4),
      dueDate: dueDate,
      categoryIndex: categoryIndex,
      tags: tags,
      subtasks: subtasks,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isInProgress: isInProgress,
      focusSessions: focusSessions,
      isArchived: isArchived,
      reminderTime: reminderTime,
    );
  }

  Task copyWith({
    String? title,
    String? description,
    int? priority,
    DateTime? dueDate,
    int? categoryIndex,
    List<String>? tags,
    List<SubTask>? subtasks,
    bool? isCompleted,
    bool? isInProgress,
    int? focusSessions,
    bool? isArchived,
    DateTime? reminderTime,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      tags: tags ?? this.tags,
      subtasks: subtasks ?? this.subtasks,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isInProgress: isInProgress ?? this.isInProgress,
      focusSessions: focusSessions ?? this.focusSessions,
      isArchived: isArchived ?? this.isArchived,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
