import '../models/habit_model.dart';
import 'date_utils_ext.dart';

class HabitStats {
  final int currentStreak;
  final int longestStreak;
  final int missedDays;
  final int totalCompletions;

  const HabitStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.missedDays,
    required this.totalCompletions,
  });
}

class StreakCalculator {
  StreakCalculator._();

  static HabitStats calculate(HabitModel habit, List<HabitLogModel> logs, {DateTime? nowOverride}) {
    final now = DateUtilsExt.stripTime(nowOverride ?? DateTime.now());
    final created = DateUtilsExt.stripTime(habit.createdAt);
    final startDate = created.isAfter(now) ? now : created;

    final Map<String, int> countByDay = {};
    for (final log in logs) {
      if (log.habitId == habit.id) {
        countByDay[log.dateKey] = (countByDay[log.dateKey] ?? 0) + log.count;
      }
    }

    int longestStreak = 0;
    int runningStreak = 0;
    int missedDays = 0;
    int totalCompletions = 0;

    // Walk forward from startDate to today
    DateTime cursor = startDate;
    while (!cursor.isAfter(now)) {
      final key = DateUtilsExt.toDateKey(cursor);
      final isScheduled = habit.isScheduledForWeekday(cursor.weekday);
      final doneCount = countByDay[key] ?? 0;
      final isCompleted = doneCount >= habit.targetCount;

      if (isCompleted) {
        totalCompletions++;
        runningStreak++;
        if (runningStreak > longestStreak) {
          longestStreak = runningStreak;
        }
      } else if (isScheduled && !habit.isPaused) {
        // Don't count today as missed if day hasn't ended yet
        if (!DateUtilsExt.isSameDay(cursor, now)) {
          missedDays++;
          runningStreak = 0;
        }
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    // Calculate current streak walking backwards from today
    int currentStreak = 0;
    DateTime backCursor = now;
    while (!backCursor.isBefore(startDate)) {
      final key = DateUtilsExt.toDateKey(backCursor);
      final isScheduled = habit.isScheduledForWeekday(backCursor.weekday);
      final isCompleted = (countByDay[key] ?? 0) >= habit.targetCount;

      if (isCompleted) {
        currentStreak++;
      } else if (isScheduled && !habit.isPaused) {
        // If today is incomplete, allow yesterday's streak to remain alive
        if (!DateUtilsExt.isSameDay(backCursor, now)) {
          break;
        }
      }
      backCursor = backCursor.subtract(const Duration(days: 1));
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    return HabitStats(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      missedDays: missedDays,
      totalCompletions: totalCompletions,
    );
  }
}
