import 'package:sqflite/sqflite.dart';
import '../models/task.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/todo_app.db';
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT DEFAULT '',
            priority INTEGER DEFAULT 0,
            dueDate INTEGER,
            categoryIndex INTEGER DEFAULT 0,
            tags TEXT DEFAULT '',
            subtasks TEXT DEFAULT '[]',
            isCompleted INTEGER DEFAULT 0,
            createdAt INTEGER NOT NULL,
            updatedAt INTEGER NOT NULL,
            isInProgress INTEGER DEFAULT 0,
            focusSessions INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  // -- CRUD Operations --

  static Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'createdAt DESC');
    return maps.map((m) => Task.fromJson(m)).toList();
  }

  static Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert('tasks', task.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update('tasks', task.toJson(),
        where: 'id = ?', whereArgs: [task.id]);
  }

  static Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearCompleted() async {
    final db = await database;
    await db.delete('tasks', where: 'isCompleted = ?', whereArgs: [1]);
  }

  static Future<void> deleteAll() async {
    final db = await database;
    await db.delete('tasks');
  }
}
