import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../models/event_model.dart';
import '../models/date_note_model.dart';

class PlannerRepository {
  final AppDatabase _dbProvider;
  PlannerRepository(this._dbProvider);

  Future<List<EventModel>> getAllEvents() async {
    final db = await _dbProvider.database;
    final rows = await db.query('events', orderBy: 'start_time ASC');
    return rows.map(EventModel.fromMap).toList();
  }

  Future<void> upsertEvent(EventModel event) async {
    final db = await _dbProvider.database;
    await db.insert(
      'events',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteEvent(String id) async {
    final db = await _dbProvider.database;
    await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<DateNoteModel>> getAllDateNotes() async {
    final db = await _dbProvider.database;
    final rows = await db.query('date_notes');
    return rows.map(DateNoteModel.fromMap).toList();
  }

  Future<void> saveDateNote(DateNoteModel note) async {
    final db = await _dbProvider.database;
    if (note.content.trim().isEmpty) {
      await db.delete('date_notes', where: 'date_key = ?', whereArgs: [note.dateKey]);
    } else {
      await db.insert(
        'date_notes',
        note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
