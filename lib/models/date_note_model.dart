class DateNoteModel {
  final String id;
  final String dateKey; // yyyy-MM-dd
  final String content;
  final DateTime updatedAt;

  const DateNoteModel({
    required this.id,
    required this.dateKey,
    required this.content,
    required this.updatedAt,
  });

  DateNoteModel copyWith({
    String? id,
    String? dateKey,
    String? content,
    DateTime? updatedAt,
  }) {
    return DateNoteModel(
      id: id ?? this.id,
      dateKey: dateKey ?? this.dateKey,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date_key': dateKey,
      'content': content,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DateNoteModel.fromMap(Map<String, dynamic> map) {
    return DateNoteModel(
      id: map['id'] as String,
      dateKey: map['date_key'] as String,
      content: (map['content'] as String?) ?? '',
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
