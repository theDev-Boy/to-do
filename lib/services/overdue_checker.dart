import 'dart:async';
import '../models/task.dart';
import '../providers/notification_provider.dart';

class OverdueChecker {
  Timer? _timer;
  final NotificationProvider notificationProvider;
  List<Task> _lastCheckedTasks = [];

  OverdueChecker(this.notificationProvider);

  void start() {
    _timer?.cancel();
    // Check every 30 seconds for overdue tasks
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkOverdue();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void updateTasks(List<Task> tasks) {
    _lastCheckedTasks = tasks;
  }

  Future<void> _checkOverdue() async {
    if (_lastCheckedTasks.isEmpty) return;
    await notificationProvider.checkAllOverdueTasks(_lastCheckedTasks);
  }

  void dispose() {
    stop();
  }
}
