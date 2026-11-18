class JournalModel {
  final String id;
  final String title;
  final String content;
  final String dateKey;
  final DateTime createdAt;

  const JournalModel({
    required this.id,
    required this.title,
    required this.content,
    required this.dateKey,
    required this.createdAt,
  });

  JournalModel copyWith({
    String? id,
    String? title,
    String? content,
    String? dateKey,
    DateTime? createdAt,
  }) {
    return JournalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      dateKey: dateKey ?? this.dateKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date_key': dateKey,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory JournalModel.fromMap(Map<String, dynamic> map) {
    return JournalModel(
      id: map['id'] as String,
      title: map['title'] as String,
      content: (map['content'] as String?) ?? '',
      dateKey: map['date_key'] as String,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
