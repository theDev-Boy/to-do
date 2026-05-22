import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'providers/notification_provider.dart';
import 'services/notification_service.dart';
import 'models/task.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final taskProvider = TaskProvider();
  await taskProvider.loadTasks();
  
  final notificationProvider = NotificationProvider();
  await notificationProvider.initialize();

  // Wire up notification tap/action callbacks
  NotificationService.onNotificationTap = (taskId) {
    // Cancel notification when tapped so it disappears
    if (taskId != null && taskId.isNotEmpty) {
      NotificationService.cancelTaskNotifications(taskId);
    }
  };
  NotificationService.onNotificationAction = (actionId, taskId) {
    if (taskId == null || taskId.isEmpty) return;
    
    final task = taskProvider.tasks.where((t) => t.id == taskId).firstOrNull;
    if (task == null) return;

    switch (actionId) {
      case 'complete':
        taskProvider.toggleComplete(task);
        // Cancel the notification on complete
        NotificationService.cancelTaskNotifications(taskId);
        break;
      case 'snooze_10':
        NotificationService.cancelTaskNotifications(taskId);
        _scheduleSnoozedNotification(task, 10, notificationProvider);
        break;
      case 'snooze_30':
        NotificationService.cancelTaskNotifications(taskId);
        _scheduleSnoozedNotification(task, 30, notificationProvider);
        break;
      case 'snooze_60':
        NotificationService.cancelTaskNotifications(taskId);
        _scheduleSnoozedNotification(task, 60, notificationProvider);
        break;
    }
  };
  
  runApp(MyApp(
    taskProvider: taskProvider,
    notificationProvider: notificationProvider,
  ));
}

/// Schedule a notification after [minutes] snooze delay
void _scheduleSnoozedNotification(Task task, int minutes, NotificationProvider provider) {
  // Use a delayed callback since flutter_local_notifications doesn't have
  // a built-in schedule with delay; we post a delayed show instead
  Future.delayed(Duration(minutes: minutes), () async {
    if (task.isCompleted) return;
    if (task.dueDate != null && task.dueDate!.isBefore(DateTime.now())) {
      final diff = DateTime.now().difference(task.dueDate!);
      await NotificationService.showOverdueNotification(task, diff.inMinutes);
    } else {
      await NotificationService.showReminderNotification(task);
    }
  });
}

class MyApp extends StatelessWidget {
  final TaskProvider taskProvider;
  final NotificationProvider notificationProvider;
  
  const MyApp({
    super.key,
    required this.taskProvider,
    required this.notificationProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: taskProvider),
        ChangeNotifierProvider.value(value: notificationProvider),
      ],
      child: MaterialApp(
        title: 'Finishly',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AppShell(),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with SingleTickerProviderStateMixin {
  final _pages = const [
    HomeScreen(),
    TasksScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  void _onTabChanged(int index) {
    context.read<TaskProvider>().setSelectedTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _pages[provider.selectedTab],
          ),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BottomNavigationBar(
                currentIndex: provider.selectedTab,
                onTap: _onTabChanged,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.today_outlined),
                    activeIcon: Icon(Icons.today),
                    label: 'Today',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list_alt_outlined),
                    activeIcon: Icon(Icons.list_alt),
                    label: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bar_chart_outlined),
                    activeIcon: Icon(Icons.bar_chart),
                    label: 'Stats',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined),
                    activeIcon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
