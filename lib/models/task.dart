enum TaskCategory {
  study,
  assignment,
  revision,
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
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  final String id;
  final String title;
  final String? description;
  final TaskCategory category;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  Task copyWith({
    String? title,
    String? description,
    TaskCategory? category,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
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
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    final String? categoryName = map['category'] as String?;
    final TaskCategory cat = categoryName != null
        ? TaskCategory.values.firstWhere(
            (TaskCategory c) => c.name == categoryName,
            orElse: () => TaskCategory.study,
          )
        : TaskCategory.study;

    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: cat,
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] == null
          ? null
          : DateTime.parse(map['completedAt'] as String),
    );
  }
}
