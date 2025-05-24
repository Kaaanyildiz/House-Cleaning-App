import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 1)
enum TaskCategory {
  @HiveField(0)
  kitchen,
  @HiveField(1)
  bathroom,
  @HiveField(2)
  general,
  @HiveField(3)
  special,
}

@HiveType(typeId: 2)
enum TaskDifficulty {
  @HiveField(0)
  easy,
  @HiveField(1)
  medium,
  @HiveField(2)
  hard,
}

@HiveType(typeId: 3)
class Task {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final TaskCategory category;
  
  @HiveField(4)
  final TaskDifficulty difficulty;
  
  @HiveField(5)
  final int points;
  
  @HiveField(6)
  final int iconCode;
  
  @HiveField(7)
  final int estimatedMinutes;
  
  @HiveField(8)
  DateTime? dueDate;
  
  @HiveField(9)
  bool isCompleted;
  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.iconCode,
    required this.estimatedMinutes,
    this.dueDate,
    this.isCompleted = false,
  }) : points = _calculatePoints(difficulty);

  // IconData için getter
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  
  static int _calculatePoints(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return 5;
      case TaskDifficulty.medium:
        return 10;
      case TaskDifficulty.hard:
        return 15;
    }
  }
  
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    TaskDifficulty? difficulty,
    int? iconCode,
    int? estimatedMinutes,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      iconCode: iconCode ?? this.iconCode,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
