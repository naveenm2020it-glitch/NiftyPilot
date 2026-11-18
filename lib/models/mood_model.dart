class MoodRecordModel {
  final String id;
  final String dateKey;
  final int moodLevel; // 1 = Low, 2 = Tired, 3 = Calm, 4 = Good, 5 = Radiant
  final String note;
  final DateTime recordedAt;

  const MoodRecordModel({
    required this.id,
    required this.dateKey,
    required this.moodLevel,
    this.note = '',
    required this.recordedAt,
  });

  String get label {
    switch (moodLevel) {
      case 1:
        return 'Low';
      case 2:
        return 'Tired';
      case 3:
        return 'Calm';
      case 4:
        return 'Good';
      case 5:
      default:
        return 'Radiant';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date_key': dateKey,
      'mood_level': moodLevel,
      'note': note,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  factory MoodRecordModel.fromMap(Map<String, dynamic> map) {
    return MoodRecordModel(
      id: map['id'] as String,
      dateKey: map['date_key'] as String,
      moodLevel: map['mood_level'] as int? ?? 4,
      note: (map['note'] as String?) ?? '',
      recordedAt: DateTime.tryParse(map['recorded_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
