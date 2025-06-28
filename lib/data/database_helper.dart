import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const nullableTextType = 'TEXT';
    const dateType = 'TEXT';

    await db.execute('''
CREATE TABLE tasks ( 
  id $idType, 
  title $textType,
  description $textType,
  isCompleted $boolType,
  priority $intType,
  dueDate $dateType,
  category $nullableTextType,
  creationDate $textType
  )
''');
  }

  // CRUD Operations
  Future<Task> createTask(Task task) async {
    final db = await instance.database;
    final id = await db.insert('tasks', _taskToMap(task));
    return task.copyWith(id: id);
  }

  Future<Task> readTask(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'tasks',
      columns: ['id', 'title', 'description', 'isCompleted', 'priority', 'dueDate', 'category', 'creationDate'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToTask(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Task>> readAllTasks() async {
    final db = await instance.database;
    const orderBy = 'creationDate DESC';
    final result = await db.query('tasks', orderBy: orderBy);

    return result.map((json) => _mapToTask(json)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return db.update(
      'tasks',
      _taskToMap(task),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Helper methods to convert between Task and Map
  Map<String, dynamic> _taskToMap(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'isCompleted': task.isCompleted ? 1 : 0,
      'priority': task.priority.index,
      'dueDate': task.dueDate?.toIso8601String(),
      'category': task.category,
      'creationDate': task.creationDate.toIso8601String(),
    };
  }

  Task _mapToTask(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      isCompleted: (map['isCompleted'] as int) == 1,
      priority: Priority.values[map['priority'] as int],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
      category: map['category'] as String?,
      creationDate: DateTime.parse(map['creationDate'] as String),
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}