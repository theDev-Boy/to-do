import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/notification_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/task_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_create_sheet.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/bulk_action_bar.dart';
import '../services/haptic_service.dart';
import '../services/overdue_checker.dart';
import 'notification_center_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  OverdueChecker? _overdueChecker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifProvider = context.read<NotificationProvider>();
      _overdueChecker = OverdueChecker(notifProvider);
      _overdueChecker!.start();
    });
  }

  @override
  void dispose() {
    _overdueChecker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TaskProvider, NotificationProvider>(
      builder: (context, provider, notifProvider, _) {
        final today = provider.todayTasks;
        final upcoming = provider.upcomingTasks;

        // Update overdue checker with latest tasks
        _overdueChecker?.updateTasks(provider.tasks);

        // Check for streak milestone
        if (notifProvider.streakMilestonesEnabled &&
            (provider.streak == 7 || provider.streak == 30 ||
             provider.streak == 100 || provider.streak == 365)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showMajorConfetti(context);
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: provider.isSelectMode
                ? Text('${provider.selectedIds.length} Selected')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM d').format(DateTime.now()),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        'Today',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
            actions: [
              if (provider.isSelectMode) ...[                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: () {
                    if (provider.selectedIds.length == today.length) {
                      provider.deselectAll();
                    } else {
                      provider.selectAll();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: provider.cancelSelectMode,
                ),
              ] else ...[
                // Notification bell
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        HapticService.light();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
                        );
                      },
                    ),
                    if (notifProvider.unreadCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.accentRed,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${notifProvider.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                // Streak badge
                Container(
                  margin: const EdgeInsets.only(right: 8, top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department, size: 16, color: AppTheme.accentAmber),
                      const SizedBox(width: 4),
                      Text(
                        '${provider.streak}',
                        style: const TextStyle(
                          color: AppTheme.accentAmber,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: provider.loadTasks,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Quick stats row
                    Row(
                      children: [
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Today', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  '${provider.totalToday}',
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${provider.completedToday} done',
                                  style: const TextStyle(color: AppTheme.accentGreen, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Overdue', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  '${provider.overdueCount}',
                                  style: TextStyle(
                                    color: provider.overdueCount > 0 ? AppTheme.accentRed : AppTheme.textSecondary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${provider.totalTasks - provider.completedCount} pending',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Progress', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  provider.totalTasks > 0
                                      ? '${(provider.completedCount / provider.totalTasks * 100).round()}%'
                                      : '0%',
                                  style: const TextStyle(
                                    color: AppTheme.accentPrimary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${provider.completedCount}/${provider.totalTasks}',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Today's tasks
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today's Tasks",
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (today.isNotEmpty)
                          Text(
                            '${today.where((t) => t.isCompleted).length}/${today.length}',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (today.isEmpty)
                      const GlassCard(
                        padding: EdgeInsets.all(32),
                        child: EmptyState(
                          icon: Icons.celebration_outlined,
                          title: 'No tasks for today!',
                          subtitle: 'Tap + to add a task',
                        ),
                      )
                    else
                      ...today.map((task) => TaskTile(
                        task: task,
                        selectMode: provider.isSelectMode,
                        isSelected: provider.selectedIds.contains(task.id),
                        onTap: () => TaskCreateSheet.show(context, task: task),
                        onToggleComplete: () => provider.toggleComplete(task),
                        onDelete: () => provider.deleteTask(task.id),
                        onSelectToggle: (selected) => provider.toggleSelected(task.id),
                      )),

                    const SizedBox(height: 24),

                    // Upcoming this week
                    if (upcoming.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Upcoming This Week',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${upcoming.length} tasks',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...upcoming.take(5).map((task) => TaskTile(
                        task: task,
                        selectMode: provider.isSelectMode,
                        isSelected: provider.selectedIds.contains(task.id),
                        onTap: () => TaskCreateSheet.show(context, task: task),
                        onToggleComplete: () => provider.toggleComplete(task),
                        onDelete: () => provider.deleteTask(task.id),
                        onSelectToggle: (selected) => provider.toggleSelected(task.id),
                      )),
                      if (upcoming.length > 5)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Center(
                            child: Text(
                              '+${upcoming.length - 5} more',
                              style: const TextStyle(color: AppTheme.accentPrimary, fontSize: 13),
                            ),
                          ),
                        ),
                    ],

                    const SizedBox(height: 100),
                  ],
                ),
              ),

              // Bulk action bar overlay
              if (provider.isSelectMode)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: const BulkActionBar(),
                ),
            ],
          ),
          floatingActionButton: provider.isSelectMode
              ? null
              : FloatingActionButton(
                  onPressed: () => TaskCreateSheet.show(context),
                  child: const Icon(Icons.add),
                ),
        );
      },
    );
  }
}
