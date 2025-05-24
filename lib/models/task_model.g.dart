// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 3;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as TaskCategory,
      difficulty: fields[4] as TaskDifficulty,
      iconCode: fields[6] as int,
      estimatedMinutes: fields[7] as int,
      dueDate: fields[8] as DateTime?,
      isCompleted: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.difficulty)
      ..writeByte(5)
      ..write(obj.points)
      ..writeByte(6)
      ..write(obj.iconCode)
      ..writeByte(7)
      ..write(obj.estimatedMinutes)
      ..writeByte(8)
      ..write(obj.dueDate)
      ..writeByte(9)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskCategoryAdapter extends TypeAdapter<TaskCategory> {
  @override
  final int typeId = 1;

  @override
  TaskCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskCategory.kitchen;
      case 1:
        return TaskCategory.bathroom;
      case 2:
        return TaskCategory.general;
      case 3:
        return TaskCategory.special;
      default:
        return TaskCategory.kitchen;
    }
  }

  @override
  void write(BinaryWriter writer, TaskCategory obj) {
    switch (obj) {
      case TaskCategory.kitchen:
        writer.writeByte(0);
        break;
      case TaskCategory.bathroom:
        writer.writeByte(1);
        break;
      case TaskCategory.general:
        writer.writeByte(2);
        break;
      case TaskCategory.special:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskDifficultyAdapter extends TypeAdapter<TaskDifficulty> {
  @override
  final int typeId = 2;

  @override
  TaskDifficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskDifficulty.easy;
      case 1:
        return TaskDifficulty.medium;
      case 2:
        return TaskDifficulty.hard;
      default:
        return TaskDifficulty.easy;
    }
  }

  @override
  void write(BinaryWriter writer, TaskDifficulty obj) {
    switch (obj) {
      case TaskDifficulty.easy:
        writer.writeByte(0);
        break;
      case TaskDifficulty.medium:
        writer.writeByte(1);
        break;
      case TaskDifficulty.hard:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskDifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
