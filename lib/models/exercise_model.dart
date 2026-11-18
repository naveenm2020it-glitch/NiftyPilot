class ExerciseRecordModel {
  final String id;
  final String dateKey;
  final String activityName;
  final int durationMinutes;
  final String notes;
  final DateTime recordedAt;

  const ExerciseRecordModel({
    required this.id,
    required this.dateKey,
    required this.activityName,
    required this.durationMinutes,
    this.notes = '',
    required this.recordedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date_key': dateKey,
      'activity_name': activityName,
      'duration_minutes': durationMinutes,
      'notes': notes,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  factory ExerciseRecordModel.fromMap(Map<String, dynamic> map) {
    return ExerciseRecordModel(
      id: map['id'] as String,
      dateKey: map['date_key'] as String,
      activityName: map['activity_name'] as String,
      durationMinutes: map['duration_minutes'] as int? ?? 30,
      notes: (map['notes'] as String?) ?? '',
      recordedAt: DateTime.tryParse(map['recorded_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
