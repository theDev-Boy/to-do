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
        'tags': tags.join(','),
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
        'isCompleted': isCompleted ? 1 : 0,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
        'isInProgress': isInProgress ? 1 : 0,
        'focusSessions': focusSessions,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        description: (json['description'] as String?) ?? '',
        priority: (json['priority'] as int?) ?? 0,
        dueDate: json['dueDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['dueDate'] as int)
            : null,
        categoryIndex: (json['categoryIndex'] as int?) ?? 0,
        tags: (json['tags'] as String?) != null && (json['tags'] as String).isNotEmpty
            ? (json['tags'] as String).split(',')
            : [],
        subtasks: json['subtasks'] != null
            ? (json['subtasks'] as List)
                .map((s) => SubTask.fromJson(s as Map<String, dynamic>))
                .toList()
            : [],
        isCompleted: (json['isCompleted'] as int?) == 1,
        createdAt: json['createdAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
            : DateTime.now(),
        isInProgress: (json['isInProgress'] as int?) == 1,
        focusSessions: (json['focusSessions'] as int?) ?? 0,
      );

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
    );
  }
}
