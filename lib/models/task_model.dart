enum TaskPriority { high, medium, low }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String dateKey; // yyyy-MM-dd (tasks stay on their assigned date)
  final String? scheduledTime; // HH:mm
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime? reminderAt;
  final int sortOrder;
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.dateKey,
    this.scheduledTime,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    this.completedAt,
    this.reminderAt,
    this.sortOrder = 0,
    required this.createdAt,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? dateKey,
    String? scheduledTime,
    bool clearScheduledTime = false,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    DateTime? reminderAt,
    bool clearReminderAt = false,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateKey: dateKey ?? this.dateKey,
      scheduledTime: clearScheduledTime ? null : (scheduledTime ?? this.scheduledTime),
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      reminderAt: clearReminderAt ? null : (reminderAt ?? this.reminderAt),
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date_key': dateKey,
      'scheduled_time': scheduledTime,
      'priority': priority.name,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
      'reminder_at': reminderAt?.toIso8601String(),
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      dateKey: map['date_key'] as String,
      scheduledTime: map['scheduled_time'] as String?,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == (map['priority'] as String? ?? 'medium'),
        orElse: () => TaskPriority.medium,
      ),
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      completedAt: map['completed_at'] != null ? DateTime.tryParse(map['completed_at'] as String) : null,
      reminderAt: map['reminder_at'] != null ? DateTime.tryParse(map['reminder_at'] as String) : null,
      sortOrder: map['sort_order'] as int? ?? 0,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
