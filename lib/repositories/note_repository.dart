import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../models/note_model.dart';

class NoteRepository {
  final AppDatabase _dbProvider;
  NoteRepository(this._dbProvider);

  Future<List<NoteModel>> getAllNotes() async {
    final db = await _dbProvider.database;
    final rows = await db.query('general_notes', orderBy: 'updated_at DESC');
    return rows.map(NoteModel.fromMap).toList();
  }

  Future<void> upsertNote(NoteModel note) async {
    final db = await _dbProvider.database;
    await db.insert(
      'general_notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteNote(String id) async {
    final db = await _dbProvider.database;
    await db.delete('general_notes', where: 'id = ?', whereArgs: [id]);
  }
}
