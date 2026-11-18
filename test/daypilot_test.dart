import 'package:daypilot_flutter/models/habit_model.dart';
import 'package:daypilot_flutter/models/task_model.dart';
import 'package:daypilot_flutter/utils/date_utils_ext.dart';
import 'package:daypilot_flutter/utils/streak_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TaskModel SQLite map round-trip preserves fields', () {
    final now = DateTime(2026, 11, 17, 9, 30);
    final task = TaskModel(
      id: 't1',
      title: 'Morning Review',
      description: 'Plan top 3 outcomes',
      dateKey: '2026-11-17',
      scheduledTime: '09:30',
      priority: TaskPriority.high,
      isCompleted: true,
      completedAt: now,
      sortOrder: 0,
      createdAt: now,
    );

    final restored = TaskModel.fromMap(task.toMap());
    expect(restored.id, 't1');
    expect(restored.title, 'Morning Review');
    expect(restored.priority, TaskPriority.high);
    expect(restored.isCompleted, true);
  });

  test('StreakCalculator computes current, longest, and missed days accurately', () {
    final start = DateTime(2026, 11, 14);
    final today = DateTime(2026, 11, 17);
    final habit = HabitModel(
      id: 'h1',
      name: 'Read 20 pages',
      colorValue: 0xFF1D6348,
      frequency: HabitFrequency.daily,
      targetCount: 1,
      createdAt: start,
    );

    final logs = [
      HabitLogModel(id: '1', habitId: 'h1', dateKey: DateUtilsExt.toDateKey(DateTime(2026, 11, 14)), count: 1),
      HabitLogModel(id: '2', habitId: 'h1', dateKey: DateUtilsExt.toDateKey(DateTime(2026, 11, 16)), count: 1),
      HabitLogModel(id: '3', habitId: 'h1', dateKey: DateUtilsExt.toDateKey(DateTime(2026, 11, 17)), count: 1),
    ];

    final stats = StreakCalculator.calculate(habit, logs, nowOverride: today);
    expect(stats.currentStreak, 2);
    expect(stats.longestStreak, 2);
    expect(stats.missedDays, 1);
    expect(stats.totalCompletions, 3);
  });
}
