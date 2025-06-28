import 'package:equatable/equatable.dart';

enum Priority { low, medium, high }

class Task extends Equatable {
  final int? id;
  final String title;
  final String description;
  final bool isCompleted;
  final Priority priority;
  final DateTime? dueDate;
  final String? category;
  final DateTime creationDate;

  const Task({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.priority = Priority.medium,
    this.dueDate,
    this.category,
    required this.creationDate,
  });

  // Add copyWith method for immutability
  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    Priority? priority,
    DateTime? dueDate,
    String? category,
    DateTime? creationDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      creationDate: creationDate ?? this.creationDate,
    );
  }

  @override
  List<Object?> get props => [id, title, description, isCompleted, priority, dueDate, category, creationDate];
}