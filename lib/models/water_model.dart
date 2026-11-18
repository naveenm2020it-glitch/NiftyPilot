class WaterRecordModel {
  final String id;
  final String dateKey;
  final int amountMl;
  final DateTime recordedAt;

  const WaterRecordModel({
    required this.id,
    required this.dateKey,
    required this.amountMl,
    required this.recordedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date_key': dateKey,
      'amount_ml': amountMl,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  factory WaterRecordModel.fromMap(Map<String, dynamic> map) {
    return WaterRecordModel(
      id: map['id'] as String,
      dateKey: map['date_key'] as String,
      amountMl: map['amount_ml'] as int? ?? 250,
      recordedAt: DateTime.tryParse(map['recorded_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
