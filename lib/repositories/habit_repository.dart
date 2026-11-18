import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../models/habit_model.dart';

class HabitRepository {
  final AppDatabase _dbProvider;
  HabitRepository(this._dbProvider);

  Future<List<HabitModel>> getAllHabits() async {
    final db = await _dbProvider.database;
    final rows = await db.query('habits', orderBy: 'created_at ASC');
    return rows.map(HabitModel.fromMap).toList();
  }

  Future<List<HabitLogModel>> getAllLogs() async {
    final db = await _dbProvider.database;
    final rows = await db.query('habit_logs');
    return rows.map(HabitLogModel.fromMap).toList();
  }

  Future<void> upsertHabit(HabitModel habit) async {
    final db = await _dbProvider.database;
    await db.insert(
      'habits',
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteHabit(String id) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      await txn.delete('habits', where: 'id = ?', whereArgs: [id]);
      await txn.delete('habit_logs', where: 'habit_id = ?', whereArgs: [id]);
    });
  }

  Future<void> setHabitLogCount({
    required String habitId,
    required String dateKey,
    required int count,
  }) async {
    final db = await _dbProvider.database;
    final logId = '${habitId}_$dateKey';
    if (count <= 0) {
      await db.delete('habit_logs', where: 'id = ?', whereArgs: [logId]);
    } else {
      await db.insert(
        'habit_logs',
        HabitLogModel(
          id: logId,
          habitId: habitId,
          dateKey: dateKey,
          count: count,
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
