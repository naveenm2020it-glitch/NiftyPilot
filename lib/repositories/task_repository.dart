import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../models/task_model.dart';

class TaskRepository {
  final AppDatabase _dbProvider;
  TaskRepository(this._dbProvider);

  Future<List<TaskModel>> getAllTasks() async {
    final db = await _dbProvider.database;
    final rows = await db.query('tasks', orderBy: 'sort_order ASC, created_at DESC');
    return rows.map(TaskModel.fromMap).toList();
  }

  Future<void> upsertTask(TaskModel task) async {
    final db = await _dbProvider.database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTaskOrders(List<TaskModel> orderedTasks) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      for (int i = 0; i < orderedTasks.length; i++) {
        await txn.update(
          'tasks',
          {'sort_order': i},
          where: 'id = ?',
          whereArgs: [orderedTasks[i].id],
        );
      }
    });
  }

  Future<void> deleteTask(String id) async {
    final db = await _dbProvider.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
