class SleepRecordModel {
  final String id;
  final String dateKey;
  final DateTime bedtime;
  final DateTime wakeTime;
  final int durationMinutes;

  const SleepRecordModel({
    required this.id,
    required this.dateKey,
    required this.bedtime,
    required this.wakeTime,
    required this.durationMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date_key': dateKey,
      'bedtime': bedtime.toIso8601String(),
      'wake_time': wakeTime.toIso8601String(),
      'duration_minutes': durationMinutes,
    };
  }

  factory SleepRecordModel.fromMap(Map<String, dynamic> map) {
    return SleepRecordModel(
      id: map['id'] as String,
      dateKey: map['date_key'] as String,
      bedtime: DateTime.tryParse(map['bedtime'] as String? ?? '') ?? DateTime.now(),
      wakeTime: DateTime.tryParse(map['wake_time'] as String? ?? '') ?? DateTime.now(),
      durationMinutes: map['duration_minutes'] as int? ?? 480,
    );
  }
}
