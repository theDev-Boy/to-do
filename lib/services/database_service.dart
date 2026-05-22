import 'package:sqflite/sqflite.dart';
import '../models/task.dart';
import 'sanitizer.dart';

/// Database service with parameterized queries to prevent SQL injection.
/// All user inputs are sanitized before reaching the database layer.
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
      // Enable foreign keys for data integrity
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // -- CRUD Operations (All parameterized queries - no SQL injection vector) --

  static Future<List<Task>> getAllTasks() async {
    final db = await database;
    // Using parameterized query via sqflite's db.query() - safe from SQL injection
    final maps = await db.query('tasks', orderBy: 'createdAt DESC');
    return maps.map((m) => Task.fromJson(m)).toList();
  }

  static Future<void> insertTask(Task task) async {
    // Validate task ID to prevent malicious data
    if (!Sanitizer.isValidId(task.id)) return;

    final db = await database;
    // db.insert() uses parameterized binding internally - safe from SQL injection
    await db.insert('tasks', task.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updateTask(Task task) async {
    // Validate task ID to prevent malicious data
    if (!Sanitizer.isValidId(task.id)) return;

    final db = await database;
    // Using parameterized where clause with whereArgs - safe from SQL injection
    await db.update('tasks', task.toJson(),
        where: 'id = ?', whereArgs: [task.id]);
  }

  static Future<void> deleteTask(String id) async {
    // Validate task ID to prevent malicious data
    if (!Sanitizer.isValidId(id)) return;

    final db = await database;
    // Using parameterized where clause with whereArgs - safe from SQL injection
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearCompleted() async {
    final db = await database;
    // Using parameterized where clause with whereArgs - safe from SQL injection
    await db.delete('tasks', where: 'isCompleted = ?', whereArgs: [1]);
  }

  static Future<void> deleteAll() async {
    final db = await database;
    await db.delete('tasks');
  }
}
