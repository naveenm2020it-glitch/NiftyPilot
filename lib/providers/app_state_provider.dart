import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../models/date_note_model.dart';
import '../models/event_model.dart';
import '../models/exercise_model.dart';
import '../models/habit_model.dart';
import '../models/journal_model.dart';
import '../models/mood_model.dart';
import '../models/note_model.dart';
import '../models/quote_model.dart';
import '../models/sleep_model.dart';
import '../models/task_model.dart';
import '../models/user_settings_model.dart';
import '../models/water_model.dart';
import '../repositories/habit_repository.dart';
import '../repositories/note_repository.dart';
import '../repositories/planner_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/task_repository.dart';
import '../repositories/wellness_repository.dart';
import '../services/backup_service.dart';
import '../services/notification_service.dart';
import '../services/quote_service.dart';
import '../services/security_service.dart';
import '../utils/date_utils_ext.dart';
import '../utils/streak_calculator.dart';

enum ProgressPeriod { daily, weekly, monthly, yearly }

class AppStateProvider extends ChangeNotifier {
  final TaskRepository _taskRepo = TaskRepository(AppDatabase.instance);
  final HabitRepository _habitRepo = HabitRepository(AppDatabase.instance);
  final PlannerRepository _plannerRepo = PlannerRepository(AppDatabase.instance);
  final NoteRepository _noteRepo = NoteRepository(AppDatabase.instance);
  final WellnessRepository _wellnessRepo = WellnessRepository(AppDatabase.instance);
  final SettingsRepository _settingsRepo = SettingsRepository();
  final QuoteService _quoteService = QuoteService();
  final SecurityService securityService = SecurityService();
  final BackupService backupService = BackupService(AppDatabase.instance);

  bool isLoading = true;
  bool isLocked = false;
  int currentTabIndex = 0;

  UserSettingsModel settings = const UserSettingsModel();
  QuoteModel? dailyQuote;

  List<TaskModel> _tasks = [];
  List<HabitModel> _habits = [];
  List<HabitLogModel> _habitLogs = [];
  List<EventModel> _events = [];
  List<NoteModel> _notes = [];
  List<DateNoteModel> _dateNotes = [];
  List<JournalModel> _journals = [];
  List<WaterRecordModel> _waterRecords = [];
  List<ExerciseRecordModel> _exerciseRecords = [];
  List<SleepRecordModel> _sleepRecords = [];
  List<MoodRecordModel> _moodRecords = [];

  List<TaskModel> get allTasks => List.unmodifiable(_tasks);
  List<HabitModel> get allHabits => List.unmodifiable(_habits);
  List<HabitLogModel> get allHabitLogs => List.unmodifiable(_habitLogs);
  List<EventModel> get allEvents => List.unmodifiable(_events);
  List<NoteModel> get allNotes => List.unmodifiable(_notes);
  List<JournalModel> get allJournals => List.unmodifiable(_journals);
  List<WaterRecordModel> get allWaterRecords => List.unmodifiable(_waterRecords);
  List<ExerciseRecordModel> get allExerciseRecords => List.unmodifiable(_exerciseRecords);
  List<SleepRecordModel> get allSleepRecords => List.unmodifiable(_sleepRecords);
  List<MoodRecordModel> get allMoodRecords => List.unmodifiable(_moodRecords);

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();

    await NotificationService.instance.initialize();
    settings = await _settingsRepo.loadSettings();
    isLocked = settings.hasPin;
    dailyQuote = await _quoteService.getDailyQuote();

    await reloadAllData();
    isLoading = false;
    notifyListeners();
  }

  Future<void> reloadAllData() async {
    _tasks = await _taskRepo.getAllTasks();
    _habits = await _habitRepo.getAllHabits();
    _habitLogs = await _habitRepo.getAllLogs();
    _events = await _plannerRepo.getAllEvents();
    _notes = await _noteRepo.getAllNotes();
    _dateNotes = await _plannerRepo.getAllDateNotes();
    _journals = await _wellnessRepo.getJournals();
    _waterRecords = await _wellnessRepo.getWaterRecords();
    _exerciseRecords = await _wellnessRepo.getExerciseRecords();
    _sleepRecords = await _wellnessRepo.getSleepRecords();
    _moodRecords = await _wellnessRepo.getMoodRecords();
    notifyListeners();
  }

  void setTabIndex(int index) {
    if (currentTabIndex == index) return;
    currentTabIndex = index;
    notifyListeners();
  }

  void unlockApp() {
    isLocked = false;
    notifyListeners();
  }

  void lockAppIfEnabled() {
    if (settings.hasPin) {
      isLocked = true;
      notifyListeners();
    }
  }

  Future<void> refreshDailyQuote() async {
    dailyQuote = await _quoteService.getDailyQuote(forceNext: true);
    notifyListeners();
  }

  List<TaskModel> tasksForDate(String dateKey) {
    final list = _tasks.where((t) => t.dateKey == dateKey).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  List<TaskModel> get completedTaskHistory {
    final list = _tasks.where((t) => t.isCompleted).toList();
    list.sort((a, b) => (b.completedAt ?? b.createdAt).compareTo(a.completedAt ?? a.createdAt));
    return list;
  }

  List<TaskModel> get overdueIncompleteTasks {
    final todayKey = DateUtilsExt.toDateKey(DateTime.now());
    return _tasks
        .where((t) => !t.isCompleted && t.dateKey.compareTo(todayKey) < 0)
        .toList();
  }

  Future<void> addOrUpdateTask({
    String? id,
    required String title,
    String description = '',
    required String dateKey,
    String? scheduledTime,
    TaskPriority priority = TaskPriority.medium,
    DateTime? reminderAt,
    bool isCompleted = false,
    DateTime? completedAt,
    int? sortOrder,
  }) async {
    final taskId = id ?? _newId();
    final existing = _tasks.where((t) => t.id == taskId).firstOrNull;
    final task = TaskModel(
      id: taskId,
      title: title.trim(),
      description: description.trim(),
      dateKey: dateKey,
      scheduledTime: scheduledTime,
      priority: priority,
      isCompleted: isCompleted,
      completedAt: completedAt,
      reminderAt: reminderAt,
      sortOrder: sortOrder ?? existing?.sortOrder ?? _tasks.length,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    await _taskRepo.upsertTask(task);
    if (reminderAt != null && !isCompleted) {
      await NotificationService.instance.scheduleOneTime(
        itemKey: 'task_$taskId',
        title: 'Task Reminder',
        body: task.title,
        scheduledAt: reminderAt,
        enabled: settings.notificationsEnabled,
      );
    } else {
      await NotificationService.instance.cancelByKey('task_$taskId');
    }
    _tasks = await _taskRepo.getAllTasks();
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(TaskModel task) async {
    final nextDone = !task.isCompleted;
    final updated = task.copyWith(
      isCompleted: nextDone,
      completedAt: nextDone ? DateTime.now() : null,
      clearCompletedAt: !nextDone,
    );
    await _taskRepo.upsertTask(updated);
    if (nextDone) {
      await NotificationService.instance.cancelByKey('task_${task.id}');
    }
    _tasks = await _taskRepo.getAllTasks();
    notifyListeners();
  }

  Future<void> reorderTasksForDate(String dateKey, int oldIndex, int newIndex) async {
    final dayTasks = tasksForDate(dateKey).where((t) => !t.isCompleted).toList();
    if (oldIndex < newIndex) newIndex -= 1;
    if (oldIndex < 0 || oldIndex >= dayTasks.length || newIndex < 0 || newIndex >= dayTasks.length) {
      return;
    }
    final moved = dayTasks.removeAt(oldIndex);
    dayTasks.insert(newIndex, moved);
    await _taskRepo.updateTaskOrders(dayTasks);
    _tasks = await _taskRepo.getAllTasks();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _taskRepo.deleteTask(id);
    await NotificationService.instance.cancelByKey('task_$id');
    _tasks = await _taskRepo.getAllTasks();
    notifyListeners();
  }

  int habitCountOnDate(String habitId, String dateKey) {
    return _habitLogs
        .where((l) => l.habitId == habitId && l.dateKey == dateKey)
        .fold(0, (sum, l) => sum + l.count);
  }

  HabitStats statsForHabit(HabitModel habit) {
    return StreakCalculator.calculate(habit, _habitLogs);
  }

  Future<void> addOrUpdateHabit({
    String? id,
    required String name,
    required int iconIndex,
    required int colorValue,
    required HabitFrequency frequency,
    required List<int> customWeekdays,
    required int targetCount,
    String? reminderTime,
    bool isPaused = false,
  }) async {
    final habitId = id ?? _newId();
    final existing = _habits.where((h) => h.id == habitId).firstOrNull;
    final habit = HabitModel(
      id: habitId,
      name: name.trim(),
      iconIndex: iconIndex,
      colorValue: colorValue,
      frequency: frequency,
      customWeekdays: customWeekdays,
      targetCount: targetCount < 1 ? 1 : targetCount,
      reminderTime: reminderTime,
      isPaused: isPaused,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    await _habitRepo.upsertHabit(habit);

    if (reminderTime != null && !isPaused) {
      await NotificationService.instance.scheduleDailyHabit(
        habitId: habitId,
        habitName: habit.name,
        timeHHmm: reminderTime,
        enabled: settings.notificationsEnabled,
      );
    } else {
      await NotificationService.instance.cancelByKey('habit_$habitId');
    }

    _habits = await _habitRepo.getAllHabits();
    notifyListeners();
  }

  Future<void> incrementHabitToday(HabitModel habit, {String? dateKey}) async {
    if (habit.isPaused) return;
    final key = dateKey ?? DateUtilsExt.toDateKey(DateTime.now());
    final current = habitCountOnDate(habit.id, key);
    final next = current >= habit.targetCount ? 0 : current + 1;
    await _habitRepo.setHabitLogCount(habitId: habit.id, dateKey: key, count: next);
    _habitLogs = await _habitRepo.getAllLogs();
    notifyListeners();
  }

  Future<void> toggleHabitPause(HabitModel habit) async {
    final updated = habit.copyWith(isPaused: !habit.isPaused);
    await _habitRepo.upsertHabit(updated);
    if (updated.isPaused) {
      await NotificationService.instance.cancelByKey('habit_${habit.id}');
    } else if (updated.reminderTime != null) {
      await NotificationService.instance.scheduleDailyHabit(
        habitId: updated.id,
        habitName: updated.name,
        timeHHmm: updated.reminderTime!,
        enabled: settings.notificationsEnabled,
      );
    }
    _habits = await _habitRepo.getAllHabits();
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    await _habitRepo.deleteHabit(id);
    await NotificationService.instance.cancelByKey('habit_$id');
    _habits = await _habitRepo.getAllHabits();
    _habitLogs = await _habitRepo.getAllLogs();
    notifyListeners();
  }

  List<EventModel> eventsForDate(DateTime date) {
    return _events.where((e) {
      final origin = DateUtilsExt.fromDateKey(e.dateKey);
      return e.occursOnDate(date, origin);
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  DateNoteModel? dateNoteFor(String dateKey) {
    return _dateNotes.where((n) => n.dateKey == dateKey).firstOrNull;
  }

  Future<void> saveDateNote(String dateKey, String content) async {
    final existing = dateNoteFor(dateKey);
    final model = DateNoteModel(
      id: existing?.id ?? 'dn_$dateKey',
      dateKey: dateKey,
      content: content,
      updatedAt: DateTime.now(),
    );
    await _plannerRepo.saveDateNote(model);
    _dateNotes = await _plannerRepo.getAllDateNotes();
    notifyListeners();
  }

  Future<void> addOrUpdateEvent({
    String? id,
    required String title,
    String description = '',
    required String dateKey,
    required String startTime,
    required String endTime,
    String category = 'Personal',
    EventRecurrence recurrence = EventRecurrence.none,
    EventStatus status = EventStatus.scheduled,
    DateTime? reminderAt,
  }) async {
    final eventId = id ?? _newId();
    final existing = _events.where((e) => e.id == eventId).firstOrNull;
    final event = EventModel(
      id: eventId,
      title: title.trim(),
      description: description.trim(),
      dateKey: dateKey,
      startTime: startTime,
      endTime: endTime,
      category: category,
      recurrence: recurrence,
      status: status,
      reminderAt: reminderAt,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    await _plannerRepo.upsertEvent(event);
    if (reminderAt != null && status == EventStatus.scheduled) {
      await NotificationService.instance.scheduleOneTime(
        itemKey: 'event_$eventId',
        title: 'Event: ${event.title}',
        body: '${event.startTime} - ${event.endTime} (${event.category})',
        scheduledAt: reminderAt,
        enabled: settings.notificationsEnabled,
      );
    } else {
      await NotificationService.instance.cancelByKey('event_$eventId');
    }
    _events = await _plannerRepo.getAllEvents();
    notifyListeners();
  }

  Future<void> cycleEventStatus(EventModel event) async {
    final nextStatus = event.status == EventStatus.scheduled
        ? EventStatus.completed
        : (event.status == EventStatus.completed
            ? EventStatus.cancelled
            : EventStatus.scheduled);
    await _plannerRepo.upsertEvent(event.copyWith(status: nextStatus));
    _events = await _plannerRepo.getAllEvents();
    notifyListeners();
  }

  Future<void> deleteEvent(String id) async {
    await _plannerRepo.deleteEvent(id);
    await NotificationService.instance.cancelByKey('event_$id');
    _events = await _plannerRepo.getAllEvents();
    notifyListeners();
  }

  Future<void> addOrUpdateNote({
    String? id,
    required String title,
    required String content,
  }) async {
    final noteId = id ?? _newId();
    final existing = _notes.where((n) => n.id == noteId).firstOrNull;
    final now = DateTime.now();
    final note = NoteModel(
      id: noteId,
      title: title.trim().isEmpty ? 'Untitled Note' : title.trim(),
      content: content.trim(),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await _noteRepo.upsertNote(note);
    _notes = await _noteRepo.getAllNotes();
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    await _noteRepo.deleteNote(id);
    _notes = await _noteRepo.getAllNotes();
    notifyListeners();
  }

  Future<void> addOrUpdateJournal({
    String? id,
    required String title,
    required String content,
    String? dateKey,
  }) async {
    final jId = id ?? _newId();
    final existing = _journals.where((j) => j.id == jId).firstOrNull;
    final entry = JournalModel(
      id: jId,
      title: title.trim().isEmpty ? 'Daily Reflection' : title.trim(),
      content: content.trim(),
      dateKey: dateKey ?? existing?.dateKey ?? DateUtilsExt.toDateKey(DateTime.now()),
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    await _wellnessRepo.upsertJournal(entry);
    _journals = await _wellnessRepo.getJournals();
    notifyListeners();
  }

  Future<void> deleteJournal(String id) async {
    await _wellnessRepo.deleteJournal(id);
    _journals = await _wellnessRepo.getJournals();
    notifyListeners();
  }

  int waterTotalForDate(String dateKey) {
    return _waterRecords
        .where((w) => w.dateKey == dateKey)
        .fold(0, (sum, w) => sum + w.amountMl);
  }

  Future<void> logWater(int amountMl, {String? dateKey}) async {
    final record = WaterRecordModel(
      id: _newId(),
      dateKey: dateKey ?? DateUtilsExt.toDateKey(DateTime.now()),
      amountMl: amountMl,
      recordedAt: DateTime.now(),
    );
    await _wellnessRepo.addWaterRecord(record);
    _waterRecords = await _wellnessRepo.getWaterRecords();
    notifyListeners();
  }

  Future<void> deleteWaterRecord(String id) async {
    await _wellnessRepo.deleteWaterRecord(id);
    _waterRecords = await _wellnessRepo.getWaterRecords();
    notifyListeners();
  }

  Future<void> logExercise({
    required String activityName,
    required int durationMinutes,
    String notes = '',
    String? dateKey,
  }) async {
    final record = ExerciseRecordModel(
      id: _newId(),
      dateKey: dateKey ?? DateUtilsExt.toDateKey(DateTime.now()),
      activityName: activityName.trim(),
      durationMinutes: durationMinutes,
      notes: notes.trim(),
      recordedAt: DateTime.now(),
    );
    await _wellnessRepo.addExerciseRecord(record);
    _exerciseRecords = await _wellnessRepo.getExerciseRecords();
    notifyListeners();
  }

  Future<void> deleteExerciseRecord(String id) async {
    await _wellnessRepo.deleteExerciseRecord(id);
    _exerciseRecords = await _wellnessRepo.getExerciseRecords();
    notifyListeners();
  }

  Future<void> logSleep({
    required DateTime bedtime,
    required DateTime wakeTime,
    String? dateKey,
  }) async {
    var effectiveWake = wakeTime;
    if (!effectiveWake.isAfter(bedtime)) {
      effectiveWake = effectiveWake.add(const Duration(days: 1));
    }
    final mins = effectiveWake.difference(bedtime).inMinutes;
    final record = SleepRecordModel(
      id: _newId(),
      dateKey: dateKey ?? DateUtilsExt.toDateKey(effectiveWake),
      bedtime: bedtime,
      wakeTime: effectiveWake,
      durationMinutes: mins,
    );
    await _wellnessRepo.addSleepRecord(record);
    _sleepRecords = await _wellnessRepo.getSleepRecords();
    notifyListeners();
  }

  Future<void> deleteSleepRecord(String id) async {
    await _wellnessRepo.deleteSleepRecord(id);
    _sleepRecords = await _wellnessRepo.getSleepRecords();
    notifyListeners();
  }

  Future<void> logMood({
    required int moodLevel,
    String note = '',
    String? dateKey,
  }) async {
    final record = MoodRecordModel(
      id: _newId(),
      dateKey: dateKey ?? DateUtilsExt.toDateKey(DateTime.now()),
      moodLevel: moodLevel,
      note: note.trim(),
      recordedAt: DateTime.now(),
    );
    await _wellnessRepo.addMoodRecord(record);
    _moodRecords = await _wellnessRepo.getMoodRecords();
    notifyListeners();
  }

  Future<void> deleteMoodRecord(String id) async {
    await _wellnessRepo.deleteMoodRecord(id);
    _moodRecords = await _wellnessRepo.getMoodRecords();
    notifyListeners();
  }

  Map<String, int> buildActivityHeatmap({int days = 84}) {
    final Map<String, int> map = {};
    final today = DateUtilsExt.stripTime(DateTime.now());
    for (int i = 0; i < days; i++) {
      final d = today.subtract(Duration(days: i));
      final key = DateUtilsExt.toDateKey(d);
      int score = 0;
      score += _tasks.where((t) => t.dateKey == key && t.isCompleted).length;
      score += _habitLogs.where((l) => l.dateKey == key && l.count > 0).length;
      if (_journals.any((j) => j.dateKey == key)) score += 1;
      if (_exerciseRecords.any((e) => e.dateKey == key)) score += 1;
      map[key] = score;
    }
    return map;
  }

  bool _isKeyInPeriod(String dateKey, ProgressPeriod period) {
    final dt = DateUtilsExt.fromDateKey(dateKey);
    final now = DateUtilsExt.stripTime(DateTime.now());
    switch (period) {
      case ProgressPeriod.daily:
        return DateUtilsExt.isSameDay(dt, now);
      case ProgressPeriod.weekly:
        final start = now.subtract(const Duration(days: 6));
        return !dt.isBefore(start) && !dt.isAfter(now);
      case ProgressPeriod.monthly:
        return dt.year == now.year && dt.month == now.month;
      case ProgressPeriod.yearly:
        return dt.year == now.year;
    }
  }

  int completedTasksInPeriod(ProgressPeriod period) =>
      _tasks.where((t) => t.isCompleted && _isKeyInPeriod(t.dateKey, period)).length;

  int pendingTasksInPeriod(ProgressPeriod period) =>
      _tasks.where((t) => !t.isCompleted && _isKeyInPeriod(t.dateKey, period)).length;

  double habitCompletionRateInPeriod(ProgressPeriod period) {
    final activeHabits = _habits.where((h) => !h.isPaused).toList();
    if (activeHabits.isEmpty) return 0.0;

    final now = DateUtilsExt.stripTime(DateTime.now());
    int daysCount;
    switch (period) {
      case ProgressPeriod.daily:
        daysCount = 1;
        break;
      case ProgressPeriod.weekly:
        daysCount = 7;
        break;
      case ProgressPeriod.monthly:
        daysCount = now.day;
        break;
      case ProgressPeriod.yearly:
        daysCount = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
        break;
    }

    int expected = 0;
    int completed = 0;
    for (int i = 0; i < daysCount; i++) {
      final d = now.subtract(Duration(days: i));
      final key = DateUtilsExt.toDateKey(d);
      for (final h in activeHabits) {
        if (d.isBefore(DateUtilsExt.stripTime(h.createdAt))) continue;
        if (h.isScheduledForWeekday(d.weekday)) {
          expected++;
          if (habitCountOnDate(h.id, key) >= h.targetCount) {
            completed++;
          }
        }
      }
    }
    if (expected == 0) return 0.0;
    return (completed / expected).clamp(0.0, 1.0);
  }

  List<double> last7DaysProductivitySeries() {
    final today = DateUtilsExt.stripTime(DateTime.now());
    return List.generate(7, (idx) {
      final day = today.subtract(Duration(days: 6 - idx));
      final key = DateUtilsExt.toDateKey(day);
      final doneTasks = _tasks.where((t) => t.dateKey == key && t.isCompleted).length;
      final doneHabits = _habitLogs.where((l) => l.dateKey == key && l.count > 0).length;
      return (doneTasks + doneHabits).toDouble();
    });
  }

  Future<void> updateSettings(UserSettingsModel updated) async {
    settings = updated;
    await _settingsRepo.saveSettings(updated);
    if (!updated.notificationsEnabled) {
      await NotificationService.instance.cancelAll();
    } else {
      await NotificationService.instance.requestPermissions();
    }
    notifyListeners();
  }
}
