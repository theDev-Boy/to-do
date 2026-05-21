import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/task_tile.dart';
import '../widgets/glass_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_create_sheet.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final filtered = provider.filteredTasks;

        return Scaffold(
          appBar: AppBar(
            title: provider.isSelectMode
                ? Text('${provider.selectedIds.length} selected')
                : const Text('All Tasks'),
            actions: [
              if (!provider.isSelectMode) ...[
                IconButton(
                  icon: Icon(
                    _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
                    color: _showFilters ? AppTheme.accentPrimary : AppTheme.textPrimary,
                  ),
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                ),
                IconButton(
                  icon: const Icon(Icons.search_outlined),
                  onPressed: () => _showSearch(context, provider),
                ),
              ] else ...[
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: provider.selectedIds.isNotEmpty
                      ? () {
                          final messenger = ScaffoldMessenger.of(context);
                          provider.completeSelected().then((_) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Tasks completed')),
                            );
                          });
                        }
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.accentRed),
                  onPressed: provider.selectedIds.isNotEmpty
                      ? () => _confirmDelete(context, provider)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: provider.toggleSelectMode,
                ),
              ],
            ],
          ),
          body: Column(
            children: [
              // Filters panel
              if (_showFilters)
                GlassCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  radius: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Priority filter
                      const Text('Priority', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _filterChip('All', provider.filterPriority == -1, () => provider.setFilterPriority(-1)),
                            ...List.generate(5, (i) => _filterChip(
                              i == 0 ? 'None' : AppTheme.priorityLabel(i),
                              provider.filterPriority == i,
                              () => provider.setFilterPriority(i),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Category filter
                      const Text('Category', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 34,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _filterChip('All', provider.filterCategory == -1, () => provider.setFilterCategory(-1)),
                            ...List.generate(AppTheme.categoryNames.length, (i) => _filterChip(
                              AppTheme.categoryNames[i],
                              provider.filterCategory == i,
                              () => provider.setFilterCategory(i),
                              color: AppTheme.categoryColors[i],
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Sort
                      Row(
                        children: [
                          const Text('Sort by', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 12),
                          _sortChip('Date', provider.sortBy == 'createdAt', () => provider.setSortBy('createdAt')),
                          const SizedBox(width: 6),
                          _sortChip('Due Date', provider.sortBy == 'dueDate', () => provider.setSortBy('dueDate')),
                          const SizedBox(width: 6),
                          _sortChip('Priority', provider.sortBy == 'priority', () => provider.setSortBy('priority')),
                          const SizedBox(width: 6),
                          _sortChip('A-Z', provider.sortBy == 'title', () => provider.setSortBy('title')),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Text('Show done', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                const SizedBox(width: 8),
                                Switch(
                                  value: provider.filterCompleted,
                                  onChanged: provider.setFilterCompleted,
                                  activeThumbColor: AppTheme.accentPrimary,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: provider.resetFilters,
                            child: const Text('Reset', style: TextStyle(color: AppTheme.accentPrimary)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Task count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} ${filtered.length == 1 ? 'task' : 'tasks'}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                    if (provider.searchQuery.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search, size: 12, color: AppTheme.accentPrimary),
                            const SizedBox(width: 4),
                            Text(
                              '"${provider.searchQuery}"',
                              style: const TextStyle(color: AppTheme.accentPrimary, fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => provider.setSearch(''),
                              child: const Icon(Icons.close, size: 12, color: AppTheme.accentPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Task list
              Expanded(
                child: filtered.isEmpty
                    ? EmptyState(
                        icon: Icons.task_alt,
                        title: provider.searchQuery.isNotEmpty
                            ? 'No tasks found'
                            : 'No tasks yet',
                        subtitle: provider.searchQuery.isNotEmpty
                            ? 'Try a different search'
                            : 'Tap + to create your first task',
                        action: provider.searchQuery.isNotEmpty
                            ? TextButton(
                                onPressed: () => provider.setSearch(''),
                                child: const Text('Clear search'),
                              )
                            : null,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => TaskTile(
                          task: filtered[i],
                          selectMode: provider.isSelectMode,
                          isSelected: provider.selectedIds.contains(filtered[i].id),
                          onTap: () => TaskCreateSheet.show(context, task: filtered[i]),
                          onToggleComplete: () => provider.toggleComplete(filtered[i]),
                          onDelete: () => provider.deleteTask(filtered[i].id),
                          onSelectToggle: (selected) => provider.toggleSelected(filtered[i].id),
                        ),
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => TaskCreateSheet.show(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _filterChip(String label, bool active, VoidCallback onTap, {Color? color}) {
    final c = color ?? AppTheme.accentPrimary;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: active ? c.withValues(alpha: 0.2) : AppTheme.bgCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? c.withValues(alpha: 0.5) : AppTheme.borderLight,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? c : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sortChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppTheme.accentPrimary.withValues(alpha: 0.15) : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? AppTheme.accentPrimary.withValues(alpha: 0.4) : AppTheme.borderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: active ? AppTheme.accentPrimary : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (active)
              Icon(
                provider.sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: AppTheme.accentPrimary,
              ),
          ],
        ),
      ),
    );
  }

  void _showSearch(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(text: provider.searchQuery);
        return AlertDialog(
          backgroundColor: AppTheme.bgDark,
          title: const Text('Search Tasks', style: TextStyle(color: AppTheme.textPrimary)),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Search by title, description, or tags...',
              prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
            ),
            onSubmitted: (v) {
              provider.setSearch(v.trim());
              Navigator.pop(ctx);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                provider.setSearch('');
                Navigator.pop(ctx);
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () {
                provider.setSearch(ctrl.text.trim());
                Navigator.pop(ctx);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgDark,
        title: const Text('Delete tasks?', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Delete ${provider.selectedIds.length} selected tasks?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteSelected();
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }
}

// For _sortChip to access the provider
extension _ProviderAccess on _TasksScreenState {
  TaskProvider get provider => context.read<TaskProvider>();
}
