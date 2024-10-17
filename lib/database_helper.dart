import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('todo.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE todos (
id INTEGER PRIMARY KEY AUTOINCREMENT,
title TEXT NOT NULL,
description TEXT NOT NULL,
isCompleted INTEGER NOT NULL
)
''');
  }

  Future<int> create(Map<String, dynamic> data) async {

    final db = await instance.database;
    return await db.insert('todos', data);
  }

  Future<List<Map<String, dynamic>>> readAll() async {
    final db = await instance.database;
    return await db.query('todos');
  }

  Future<int> update(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.update(
      'todos',
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(

      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// Method to execute any raw SQL query
  Future<dynamic> executeRawQuery(String query) async {
    final db = await database;
    if (db != null) {
      if (query.toLowerCase().startsWith("select")) {
        return await db.rawQuery(query);
      } else {
        return await db.execute(query);
      }
    }
  }
}