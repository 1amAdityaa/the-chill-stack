import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/test_result.dart';
import '../models/user.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  factory DatabaseService() => instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sai_sports.db');

    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE test_results (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        testType TEXT NOT NULL,
        score REAL NOT NULL,
        videoPath TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isVerified INTEGER DEFAULT 0,
        isSynced INTEGER DEFAULT 0,
        metadata TEXT
      )
    ''');
  }

  Future<void> insertTestResult(TestResult result) async {
    final db = await database;
    await db.insert(
      'test_results',
      result.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TestResult>> getTestResults(String userId) async {
    final db = await database;
    final maps = await db.query(
      'test_results',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => TestResult.fromJson(map)).toList();
  }
}
