import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/category_icon.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final byCategory = provider.tasksByCategory;
        final byPriority = provider.tasksByPriority;
        final history = provider.completionHistory;
        final total = provider.totalTasks;
        final completed = provider.completedCount;
        final streak = provider.streak;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Overview cards
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline, color: AppTheme.accentGreen, size: 24),
                          const SizedBox(height: 10),
                          Text(
                            total > 0 ? '${(completed / total * 100).round()}%' : '0%',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '$completed / $total done',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.local_fire_department, color: AppTheme.accentAmber, size: 24),
                          const SizedBox(height: 10),
                          Text(
                            '$streak',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'day streak',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber, color: AppTheme.accentRed, size: 24),
                          const SizedBox(height: 10),
                          Text(
                            '${provider.overdueCount}',
                            style: TextStyle(
                              color: provider.overdueCount > 0 ? AppTheme.accentRed : AppTheme.textSecondary,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'overdue',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Completion this week
              const Text(
                'This Week',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tasks Completed',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                        Text(
                          '${history.fold(0, (a, b) => a + b)} total',
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 60,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(7, (i) {
                          final count = history[i];
                          final max = history.reduce((a, b) => a > b ? a : b);
                          final heightRatio = max > 0 ? count / max : 0.0;
                          final now = DateTime.now();
                          // Offset to get correct day name
                          final dayOfWeek = now.subtract(Duration(days: 6 - i));

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (count > 0)
                                    Text(
                                      '$count',
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: count > 0
                                            ? AppTheme.accentPrimary.withValues(alpha: 0.3 + heightRatio * 0.7)
                                            : AppTheme.bgCard,
                                        borderRadius: BorderRadius.circular(6),
                                        border: count > 0
                                            ? Border.all(color: AppTheme.accentPrimary.withValues(alpha: 0.3))
                                            : null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    DateFormat('E').format(dayOfWeek).substring(0, 3),
                                    style: TextStyle(
                                      color: count > 0 ? AppTheme.textPrimary : AppTheme.textSecondary,
                                      fontSize: 10,
                                      fontWeight: count > 0 ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Category breakdown
              const Text(
                'By Category',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: byCategory.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No active tasks', style: TextStyle(color: AppTheme.textSecondary)),
                        ),
                      )
                    : Column(
                        children: byCategory.entries.map((e) {
                          final totalCat = byCategory.values.fold(0, (a, b) => a + b);
                          final fraction = e.value / totalCat;
                          final color = AppTheme.categoryColors[e.key % AppTheme.categoryColors.length];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                CategoryIcon(index: e.key, compact: true),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    AppTheme.categoryNames[e.key % AppTheme.categoryNames.length],
                                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: fraction,
                                      backgroundColor: AppTheme.bgCard,
                                      valueColor: AlwaysStoppedAnimation(color),
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 28,
                                  child: Text(
                                    '${(fraction * 100).round()}%',
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 24),

              // Priority breakdown
              const Text(
                'By Priority',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: byPriority.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No active tasks', style: TextStyle(color: AppTheme.textSecondary)),
                        ),
                      )
                    : Column(
                        children: byPriority.entries.map((e) {
                          final totalP = byPriority.values.fold(0, (a, b) => a + b);
                          final fraction = e.value / totalP;
                          final color = AppTheme.priorityColor(e.key);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    e.key == 0 ? 'None' : AppTheme.priorityLabel(e.key),
                                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: fraction,
                                      backgroundColor: AppTheme.bgCard,
                                      valueColor: AlwaysStoppedAnimation(color),
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 28,
                                  child: Text(
                                    '${(fraction * 100).round()}%',
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }
}
