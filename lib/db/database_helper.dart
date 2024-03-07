import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
  Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'qr_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE qr_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data TEXT,
            time_in INTEGER,
            time_out INTEGER
          )
          ''',
        );
        await db.execute(
          '''
          CREATE TABLE user (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          )
        ''',
        );
      },
    );
  }

  Future<int> insertQRData(String data, int timeIn, int timeOut) async {
    final db = await database;
    if (db == null) {
      return -1;
    }
    final existingData = await db.query(
      'qr_data',
      where: 'data = ?',
      whereArgs: [data],
    );
    if (existingData.isNotEmpty) {
      final existingEntry = existingData.first;
      final id = existingEntry['id'] as int;
      final existingTimeIn = existingEntry['time_in'] as int;
      final existingTimeOut = existingEntry['time_out'] as int;
      if (existingTimeIn != 0 && existingTimeOut == 0) {
        await db.update('qr_data', {'time_out': timeOut},
            where: 'id = ?', whereArgs: [id]);
        return id;
      }
    }
    return await db.insert(
        'qr_data', {'data': data, 'time_in': timeIn, 'time_out': timeOut});
  }

  Future<List<Map<String, dynamic>>> getQRData() async {
    final db = await database;
    if (db == null) {
      return [];
    }
    return await db.query('qr_data');
  }

  Future<int> updateQRDataTimeOut(int id, int timeOut) async {
    final db = await database;
    if (db == null) {
      return -1;
    }
    return await db.update('qr_data', {'time_out': timeOut},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertUser(String name) async {
    final db = await database;
    return await db!.insert('user', {'name': name});
  }

  Future<String?> getUser() async {
    final db = await database;
    final result = await db!.query('user');
    if (result.isNotEmpty) {
      return result.first['name'] as String;
    } else {
      return '';
    }
  }

  Future<void> deleteUser() async {
    final db = await database;
    await db!.delete('user');
  }
}
