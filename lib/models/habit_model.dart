enum HabitFrequency { daily, weekly, custom }

class HabitModel {
  final String id;
  final String name;
  final int iconIndex;
  final int colorValue;
  final HabitFrequency frequency;
  final List<int> customWeekdays; // 1 = Mon .. 7 = Sun
  final int targetCount;
  final String? reminderTime; // HH:mm
  final bool isPaused;
  final DateTime createdAt;

  const HabitModel({
    required this.id,
    required this.name,
    this.iconIndex = 0,
    required this.colorValue,
    this.frequency = HabitFrequency.daily,
    this.customWeekdays = const [1, 2, 3, 4, 5, 6, 7],
    this.targetCount = 1,
    this.reminderTime,
    this.isPaused = false,
    required this.createdAt,
  });

  bool isScheduledForWeekday(int weekday) {
    if (frequency == HabitFrequency.daily) return true;
    return customWeekdays.contains(weekday);
  }

  HabitModel copyWith({
    String? id,
    String? name,
    int? iconIndex,
    int? colorValue,
    HabitFrequency? frequency,
    List<int>? customWeekdays,
    int? targetCount,
    String? reminderTime,
    bool clearReminder = false,
    bool? isPaused,
    DateTime? createdAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconIndex: iconIndex ?? this.iconIndex,
      colorValue: colorValue ?? this.colorValue,
      frequency: frequency ?? this.frequency,
      customWeekdays: customWeekdays ?? this.customWeekdays,
      targetCount: targetCount ?? this.targetCount,
      reminderTime: clearReminder ? null : (reminderTime ?? this.reminderTime),
      isPaused: isPaused ?? this.isPaused,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_index': iconIndex,
      'color_value': colorValue,
      'frequency': frequency.name,
      'custom_weekdays': customWeekdays.join(','),
      'target_count': targetCount,
      'reminder_time': reminderTime,
      'is_paused': isPaused ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    final rawDays = (map['custom_weekdays'] as String?) ?? '1,2,3,4,5,6,7';
    final parsedDays = rawDays
        .split(',')
        .where((e) => e.trim().isNotEmpty)
        .map((e) => int.tryParse(e.trim()) ?? 1)
        .toList();

    return HabitModel(
      id: map['id'] as String,
      name: map['name'] as String,
      iconIndex: map['icon_index'] as int? ?? 0,
      colorValue: map['color_value'] as int? ?? 0xFF1D6348,
      frequency: HabitFrequency.values.firstWhere(
        (e) => e.name == (map['frequency'] as String? ?? 'daily'),
        orElse: () => HabitFrequency.daily,
      ),
      customWeekdays: parsedDays.isEmpty ? [1, 2, 3, 4, 5, 6, 7] : parsedDays,
      targetCount: map['target_count'] as int? ?? 1,
      reminderTime: map['reminder_time'] as String?,
      isPaused: (map['is_paused'] as int? ?? 0) == 1,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class HabitLogModel {
  final String id;
  final String habitId;
  final String dateKey;
  final int count;

  const HabitLogModel({
    required this.id,
    required this.habitId,
    required this.dateKey,
    this.count = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'date_key': dateKey,
      'count': count,
    };
  }

  factory HabitLogModel.fromMap(Map<String, dynamic> map) {
    return HabitLogModel(
      id: map['id'] as String,
      habitId: map['habit_id'] as String,
      dateKey: map['date_key'] as String,
      count: map['count'] as int? ?? 1,
    );
  }
}
