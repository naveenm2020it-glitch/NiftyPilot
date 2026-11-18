enum EventRecurrence { none, daily, weekly, monthly }
enum EventStatus { scheduled, completed, cancelled }

class EventModel {
  final String id;
  final String title;
  final String description;
  final String dateKey; // yyyy-MM-dd start date
  final String startTime; // HH:mm
  final String endTime; // HH:mm
  final String category;
  final EventRecurrence recurrence;
  final EventStatus status;
  final DateTime? reminderAt;
  final DateTime createdAt;

  const EventModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.dateKey,
    required this.startTime,
    required this.endTime,
    this.category = 'Personal',
    this.recurrence = EventRecurrence.none,
    this.status = EventStatus.scheduled,
    this.reminderAt,
    required this.createdAt,
  });

  bool occursOnDate(DateTime target, DateTime origin) {
    final t = DateTime(target.year, target.month, target.day);
    final o = DateTime(origin.year, origin.month, origin.day);
    if (t.isBefore(o)) return false;
    if (t.year == o.year && t.month == o.month && t.day == o.day) return true;

    switch (recurrence) {
      case EventRecurrence.none:
        return false;
      case EventRecurrence.daily:
        return true;
      case EventRecurrence.weekly:
        return t.weekday == o.weekday;
      case EventRecurrence.monthly:
        return t.day == o.day;
    }
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? dateKey,
    String? startTime,
    String? endTime,
    String? category,
    EventRecurrence? recurrence,
    EventStatus? status,
    DateTime? reminderAt,
    bool clearReminder = false,
    DateTime? createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateKey: dateKey ?? this.dateKey,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      recurrence: recurrence ?? this.recurrence,
      status: status ?? this.status,
      reminderAt: clearReminder ? null : (reminderAt ?? this.reminderAt),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date_key': dateKey,
      'start_time': startTime,
      'end_time': endTime,
      'category': category,
      'recurrence': recurrence.name,
      'status': status.name,
      'reminder_at': reminderAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      dateKey: map['date_key'] as String,
      startTime: (map['start_time'] as String?) ?? '09:00',
      endTime: (map['end_time'] as String?) ?? '10:00',
      category: (map['category'] as String?) ?? 'Personal',
      recurrence: EventRecurrence.values.firstWhere(
        (e) => e.name == (map['recurrence'] as String? ?? 'none'),
        orElse: () => EventRecurrence.none,
      ),
      status: EventStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String? ?? 'scheduled'),
        orElse: () => EventStatus.scheduled,
      ),
      reminderAt: map['reminder_at'] != null ? DateTime.tryParse(map['reminder_at'] as String) : null,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
