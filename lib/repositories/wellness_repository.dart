import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../models/journal_model.dart';
import '../models/water_model.dart';
import '../models/exercise_model.dart';
import '../models/sleep_model.dart';
import '../models/mood_model.dart';

class WellnessRepository {
  final AppDatabase _dbProvider;
  WellnessRepository(this._dbProvider);

  // Journal
  Future<List<JournalModel>> getJournals() async {
    final db = await _dbProvider.database;
    final rows = await db.query('journal_entries', orderBy: 'created_at DESC');
    return rows.map(JournalModel.fromMap).toList();
  }

  Future<void> upsertJournal(JournalModel entry) async {
    final db = await _dbProvider.database;
    await db.insert('journal_entries', entry.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteJournal(String id) async {
    final db = await _dbProvider.database;
    await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
  }

  // Water
  Future<List<WaterRecordModel>> getWaterRecords() async {
    final db = await _dbProvider.database;
    final rows = await db.query('water_records', orderBy: 'recorded_at DESC');
    return rows.map(WaterRecordModel.fromMap).toList();
  }

  Future<void> addWaterRecord(WaterRecordModel record) async {
    final db = await _dbProvider.database;
    await db.insert('water_records', record.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteWaterRecord(String id) async {
    final db = await _dbProvider.database;
    await db.delete('water_records', where: 'id = ?', whereArgs: [id]);
  }

  // Exercise
  Future<List<ExerciseRecordModel>> getExerciseRecords() async {
    final db = await _dbProvider.database;
    final rows = await db.query('exercise_records', orderBy: 'recorded_at DESC');
    return rows.map(ExerciseRecordModel.fromMap).toList();
  }

  Future<void> addExerciseRecord(ExerciseRecordModel record) async {
    final db = await _dbProvider.database;
    await db.insert('exercise_records', record.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteExerciseRecord(String id) async {
    final db = await _dbProvider.database;
    await db.delete('exercise_records', where: 'id = ?', whereArgs: [id]);
  }

  // Sleep
  Future<List<SleepRecordModel>> getSleepRecords() async {
    final db = await _dbProvider.database;
    final rows = await db.query('sleep_records', orderBy: 'wake_time DESC');
    return rows.map(SleepRecordModel.fromMap).toList();
  }

  Future<void> addSleepRecord(SleepRecordModel record) async {
    final db = await _dbProvider.database;
    await db.insert('sleep_records', record.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteSleepRecord(String id) async {
    final db = await _dbProvider.database;
    await db.delete('sleep_records', where: 'id = ?', whereArgs: [id]);
  }

  // Mood
  Future<List<MoodRecordModel>> getMoodRecords() async {
    final db = await _dbProvider.database;
    final rows = await db.query('mood_records', orderBy: 'recorded_at DESC');
    return rows.map(MoodRecordModel.fromMap).toList();
  }

  Future<void> addMoodRecord(MoodRecordModel record) async {
    final db = await _dbProvider.database;
    await db.insert('mood_records', record.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteMoodRecord(String id) async {
    final db = await _dbProvider.database;
    await db.delete('mood_records', where: 'id = ?', whereArgs: [id]);
  }
}
