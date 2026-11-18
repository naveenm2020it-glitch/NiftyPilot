import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../core/constants/app_constants.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        date_key TEXT NOT NULL,
        scheduled_time TEXT,
        priority TEXT NOT NULL DEFAULT 'medium',
        is_completed INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT,
        reminder_at TEXT,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_tasks_date ON tasks(date_key)');

    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon_index INTEGER NOT NULL DEFAULT 0,
        color_value INTEGER NOT NULL,
        frequency TEXT NOT NULL DEFAULT 'daily',
        custom_weekdays TEXT NOT NULL DEFAULT '1,2,3,4,5,6,7',
        target_count INTEGER NOT NULL DEFAULT 1,
        reminder_time TEXT,
        is_paused INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_logs (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        date_key TEXT NOT NULL,
        count INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('CREATE INDEX idx_habit_logs_habit_date ON habit_logs(habit_id, date_key)');

    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        date_key TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'Personal',
        recurrence TEXT NOT NULL DEFAULT 'none',
        status TEXT NOT NULL DEFAULT 'scheduled',
        reminder_at TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_events_date ON events(date_key)');

    await db.execute('''
      CREATE TABLE general_notes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE date_notes (
        id TEXT PRIMARY KEY,
        date_key TEXT UNIQUE NOT NULL,
        content TEXT NOT NULL DEFAULT '',
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_date_notes_date ON date_notes(date_key)');

    await db.execute('''
      CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL DEFAULT '',
        date_key TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE water_records (
        id TEXT PRIMARY KEY,
        date_key TEXT NOT NULL,
        amount_ml INTEGER NOT NULL,
        recorded_at TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_water_date ON water_records(date_key)');

    await db.execute('''
      CREATE TABLE exercise_records (
        id TEXT PRIMARY KEY,
        date_key TEXT NOT NULL,
        activity_name TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        recorded_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sleep_records (
        id TEXT PRIMARY KEY,
        date_key TEXT NOT NULL,
        bedtime TEXT NOT NULL,
        wake_time TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE mood_records (
        id TEXT PRIMARY KEY,
        date_key TEXT NOT NULL,
        mood_level INTEGER NOT NULL,
        note TEXT NOT NULL DEFAULT '',
        recorded_at TEXT NOT NULL
      )
    ''');
  }

  Future<Map<String, List<Map<String, dynamic>>>> exportAllTables() async {
    final db = await database;
    const tables = [
      'tasks',
      'habits',
      'habit_logs',
      'events',
      'general_notes',
      'date_notes',
      'journal_entries',
      'water_records',
      'exercise_records',
      'sleep_records',
      'mood_records',
    ];
    final Map<String, List<Map<String, dynamic>>> snapshot = {};
    for (final table in tables) {
      snapshot[table] = await db.query(table);
    }
    return snapshot;
  }

  Future<void> restoreAllTables(Map<String, dynamic> snapshot) async {
    final db = await database;
    await db.transaction((txn) async {
      const tables = [
        'tasks',
        'habits',
        'habit_logs',
        'events',
        'general_notes',
        'date_notes',
        'journal_entries',
        'water_records',
        'exercise_records',
        'sleep_records',
        'mood_records',
      ];
      for (final table in tables) {
        if (snapshot.containsKey(table) && snapshot[table] is List) {
          await txn.delete(table);
          for (final row in (snapshot[table] as List)) {
            if (row is Map<String, dynamic>) {
              await txn.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
            } else if (row is Map) {
              await txn.insert(
                table,
                Map<String, dynamic>.from(row),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
        }
      }
    });
  }
}
