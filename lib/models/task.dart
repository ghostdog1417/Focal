enum TaskCategory {
  study,
  assignment,
  revision,
}

enum TaskPriority {
  low,
  medium,
  high,
}

extension TaskPriorityExtension on TaskPriority {
  String get display {
    return switch (this) {
      TaskPriority.low => 'Low',
      TaskPriority.medium => 'Medium',
      TaskPriority.high => 'High',
    };
  }

  int get weight {
    return switch (this) {
      TaskPriority.low => 1,
      TaskPriority.medium => 2,
      TaskPriority.high => 3,
    };
  }
}

enum HabitFrequency {
  daily,
  weekdays,
  custom,
}

extension HabitFrequencyExtension on HabitFrequency {
  String get display {
    return switch (this) {
      HabitFrequency.daily => 'Daily',
      HabitFrequency.weekdays => 'Weekdays',
      HabitFrequency.custom => 'Custom days',
    };
  }
}

extension TaskCategoryExtension on TaskCategory {
  String get display {
    return switch (this) {
      TaskCategory.study => 'Study',
      TaskCategory.assignment => 'Assignment',
      TaskCategory.revision => 'Revision',
    };
  }

  String get emoji {
    return switch (this) {
      TaskCategory.study => '📚',
      TaskCategory.assignment => '📝',
      TaskCategory.revision => '🔁',
    };
  }
}

class Task {
  const Task({
    required this.id,
    required this.title,
    this.description,
    this.category = TaskCategory.study,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.estimatedMinutes = 30,
    this.isHabit = false,
    this.habitFrequency = HabitFrequency.daily,
    this.customWeekdays = const <int>[],
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  final String id;
  final String title;
  final String? description;
  final TaskCategory category;
  final TaskPriority priority;
  final DateTime? dueDate;
  final int estimatedMinutes;
  final bool isHabit;
  final HabitFrequency habitFrequency;
  final List<int> customWeekdays;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  Task copyWith({
    String? title,
    String? description,
    TaskCategory? category,
    TaskPriority? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
    int? estimatedMinutes,
    bool? isHabit,
    HabitFrequency? habitFrequency,
    List<int>? customWeekdays,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isHabit: isHabit ?? this.isHabit,
      habitFrequency: habitFrequency ?? this.habitFrequency,
      customWeekdays: customWeekdays ?? this.customWeekdays,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'estimatedMinutes': estimatedMinutes,
      'isHabit': isHabit,
      'habitFrequency': habitFrequency.name,
      'customWeekdays': customWeekdays,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    final String? categoryName = map['category'] as String?;
    final String? priorityName = map['priority'] as String?;
    final String? habitFrequencyName = map['habitFrequency'] as String?;
    final List<int> customWeekdays = (map['customWeekdays'] as List<dynamic>? ??
        const <dynamic>[])
      .map((dynamic value) => (value as num).toInt())
      .where((int day) => day >= DateTime.monday && day <= DateTime.sunday)
      .toList();

    final TaskCategory cat = categoryName != null
        ? TaskCategory.values.firstWhere(
            (TaskCategory c) => c.name == categoryName,
            orElse: () => TaskCategory.study,
          )
        : TaskCategory.study;

    final TaskPriority priority = priorityName != null
        ? TaskPriority.values.firstWhere(
            (TaskPriority p) => p.name == priorityName,
            orElse: () => TaskPriority.medium,
          )
        : TaskPriority.medium;

    final HabitFrequency habitFrequency = habitFrequencyName != null
        ? HabitFrequency.values.firstWhere(
            (HabitFrequency h) => h.name == habitFrequencyName,
            orElse: () => HabitFrequency.daily,
          )
        : HabitFrequency.daily;

    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: cat,
      priority: priority,
      dueDate: map['dueDate'] == null
          ? null
          : DateTime.tryParse(map['dueDate'] as String),
      estimatedMinutes: (map['estimatedMinutes'] as num?)?.toInt() ?? 30,
      isHabit: map['isHabit'] as bool? ?? false,
      habitFrequency: habitFrequency,
      customWeekdays: customWeekdays,
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] == null
          ? null
          : DateTime.parse(map['completedAt'] as String),
    );
  }

  bool isHabitDueOn(DateTime date) {
    if (!isHabit) return false;

    return switch (habitFrequency) {
      HabitFrequency.daily => true,
      HabitFrequency.weekdays =>
        date.weekday >= DateTime.monday && date.weekday <= DateTime.friday,
      HabitFrequency.custom => customWeekdays.contains(date.weekday),
    };
  }

  String get habitScheduleDisplay {
    return switch (habitFrequency) {
      HabitFrequency.daily => 'Daily',
      HabitFrequency.weekdays => 'Weekdays',
      HabitFrequency.custom => customWeekdays.isEmpty
          ? 'Custom'
          : customWeekdays.map(_weekdayShort).join(', '),
    };
  }

  static String _weekdayShort(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'Mon',
      DateTime.tuesday => 'Tue',
      DateTime.wednesday => 'Wed',
      DateTime.thursday => 'Thu',
      DateTime.friday => 'Fri',
      DateTime.saturday => 'Sat',
      DateTime.sunday => 'Sun',
      _ => '?',
    };
  }
}
