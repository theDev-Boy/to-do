import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _filterPriority = -1; // -1 = all
  int _filterCategory = -1;
  bool _filterCompleted = true;
  String _sortBy = 'createdAt'; // createdAt, dueDate, priority, title
  bool _sortAsc = false;
  int _selectedTab = 0;
  bool _isSelectMode = false;
  final Set<String> _selectedIds = {};

  // Getters
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  int get filterPriority => _filterPriority;
  int get filterCategory => _filterCategory;
  bool get filterCompleted => _filterCompleted;
  String get sortBy => _sortBy;
  bool get sortAsc => _sortAsc;
  int get selectedTab => _selectedTab;
  bool get isSelectMode => _isSelectMode;
  Set<String> get selectedIds => _selectedIds;

  List<Task> get filteredTasks {
    var list = List<Task>.from(_tasks);

    // Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((t) =>
          t.title.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q) ||
          t.tags.any((tag) => tag.toLowerCase().contains(q))).toList();
    }

    // Priority filter
    if (_filterPriority >= 0) {
      list = list.where((t) => t.priority == _filterPriority).toList();
    }

    // Category filter
    if (_filterCategory >= 0) {
      list = list.where((t) => t.categoryIndex == _filterCategory).toList();
    }

    // Completed filter
    if (!_filterCompleted) {
      list = list.where((t) => !t.isCompleted).toList();
    }

    // Sort
    list.sort((a, b) {
      int cmp;
      switch (_sortBy) {
        case 'priority':
          cmp = b.priority.compareTo(a.priority);
          break;
        case 'dueDate':
          if (a.dueDate == null && b.dueDate == null) cmp = 0;
          else if (a.dueDate == null) cmp = 1;
          else if (b.dueDate == null) cmp = -1;
          else cmp = a.dueDate!.compareTo(b.dueDate!);
          break;
        case 'title':
          cmp = a.title.compareTo(b.title);
          break;
        default:
          cmp = a.createdAt.compareTo(b.createdAt);
      }
      return _sortAsc ? cmp : -cmp;
    });

    return list;
  }

  List<Task> get todayTasks {
    final now = DateTime.now();
    return _tasks.where((t) {
      if (t.isCompleted) return false;
      if (t.dueDate == null) return false;
      return t.dueDate!.year == now.year &&
          t.dueDate!.month == now.month &&
          t.dueDate!.day == now.day;
    }).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  List<Task> get upcomingTasks {
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));
    return _tasks.where((t) {
      if (t.isCompleted) return false;
      if (t.dueDate == null) return false;
      return t.dueDate!.isAfter(now) && t.dueDate!.isBefore(weekEnd);
    }).toList()
      ..sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
  }

  List<Task> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  int get totalToday => todayTasks.length;
  int get completedToday =>
      todayTasks.where((t) => t.isCompleted).length;
  int get totalTasks => _tasks.length;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get overdueCount =>
      _tasks.where((t) => t.isOverdue).length;
  int get inProgressCount =>
      _tasks.where((t) => t.isInProgress).length;

  // --- Methods ---

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    _tasks = await DatabaseService.getAllTasks();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    String description = '',
    int priority = 0,
    DateTime? dueDate,
    int categoryIndex = 0,
    List<String>? tags,
    List<SubTask>? subtasks,
  }) async {
    final task = Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      categoryIndex: categoryIndex,
      tags: tags,
      subtasks: subtasks,
    );
    await DatabaseService.insertTask(task);
    _tasks.insert(0, task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final updated = task.copyWith();
    await DatabaseService.updateTask(updated);
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx >= 0) {
      _tasks[idx] = updated;
    }
    notifyListeners();
  }

  Future<void> toggleComplete(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await DatabaseService.updateTask(updated);
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx >= 0) {
      _tasks[idx] = updated;
    }
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await DatabaseService.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    _selectedIds.remove(id);
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    for (final id in _selectedIds) {
      await DatabaseService.deleteTask(id);
    }
    _tasks.removeWhere((t) => _selectedIds.contains(t.id));
    _selectedIds.clear();
    _isSelectMode = false;
    notifyListeners();
  }

  Future<void> completeSelected() async {
    for (final id in _selectedIds) {
      final idx = _tasks.indexWhere((t) => t.id == id);
      if (idx >= 0) {
        final updated = _tasks[idx].copyWith(isCompleted: true);
        await DatabaseService.updateTask(updated);
        _tasks[idx] = updated;
      }
    }
    _selectedIds.clear();
    _isSelectMode = false;
    notifyListeners();
  }

  Future<void> clearCompleted() async {
    await DatabaseService.clearCompleted();
    _tasks.removeWhere((t) => t.isCompleted);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    await DatabaseService.deleteAll();
    _tasks.clear();
    notifyListeners();
  }

  void toggleSelectMode() {
    _isSelectMode = !_isSelectMode;
    _selectedIds.clear();
    notifyListeners();
  }

  void toggleSelected(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
      if (_selectedIds.isEmpty) _isSelectMode = false;
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterPriority(int priority) {
    _filterPriority = priority;
    notifyListeners();
  }

  void setFilterCategory(int index) {
    _filterCategory = index;
    notifyListeners();
  }

  void setFilterCompleted(bool show) {
    _filterCompleted = show;
    notifyListeners();
  }

  void setSortBy(String field) {
    if (_sortBy == field) {
      _sortAsc = !_sortAsc;
    } else {
      _sortBy = field;
      _sortAsc = false;
    }
    notifyListeners();
  }

  void setSelectedTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _filterPriority = -1;
    _filterCategory = -1;
    _filterCompleted = true;
    _sortBy = 'createdAt';
    _sortAsc = false;
    notifyListeners();
  }

  // Stats
  Map<int, int> get tasksByCategory {
    final map = <int, int>{};
    for (final t in _tasks) {
      if (!t.isCompleted) {
        map[t.categoryIndex] = (map[t.categoryIndex] ?? 0) + 1;
      }
    }
    return map;
  }

  Map<int, int> get tasksByPriority {
    final map = <int, int>{};
    for (final t in _tasks) {
      if (!t.isCompleted) {
        map[t.priority] = (map[t.priority] ?? 0) + 1;
      }
    }
    return map;
  }

  List<int> get completionHistory {
    final now = DateTime.now();
    final list = <int>[];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final count = _tasks.where((t) {
        if (!t.isCompleted) return false;
        return t.updatedAt.year == day.year &&
            t.updatedAt.month == day.month &&
            t.updatedAt.day == day.day;
      }).length;
      list.add(count);
    }
    return list;
  }

  int get streak {
    int count = 0;
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final day = now.subtract(Duration(days: i));
      final hasCompletion = _tasks.any((t) =>
          t.isCompleted &&
          t.updatedAt.year == day.year &&
          t.updatedAt.month == day.month &&
          t.updatedAt.day == day.day);
      if (hasCompletion) {
        count++;
      } else if (i > 0) {
        break;
      }
    }
    return count;
  }
}
