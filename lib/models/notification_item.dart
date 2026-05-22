class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String? taskId;
  final NotificationType type;
  final DateTime createdAt;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.taskId,
    required this.type,
    DateTime? createdAt,
    this.isRead = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'taskId': taskId,
        'type': type.index,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'isRead': isRead ? 1 : 0,
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        taskId: json['taskId'] as String?,
        type: NotificationType.values[json['type'] as int],
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
        isRead: (json['isRead'] as int) == 1,
      );
}

enum NotificationType {
  overdue,
  dueSoon,
  reminder,
  dailyDigest,
  streakMilestone,
  focusComplete,
  taskShared,
}
