import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class IconDataAdapter extends TypeAdapter<IconData> {
  @override
  final int typeId = 201;

  @override
  IconData read(BinaryReader reader) {
    final codePoint = reader.readInt();
    final fontFamily = reader.readString();
    final fontPackage = reader.readString();
    final matchTextDirection = reader.readBool();

    return IconData(
      codePoint,
      fontFamily: fontFamily.isEmpty ? null : fontFamily,
      fontPackage: fontPackage.isEmpty ? null : fontPackage,
      matchTextDirection: matchTextDirection,
    );
  }

  @override
  void write(BinaryWriter writer, IconData obj) {
    writer.writeInt(obj.codePoint);
    writer.writeString(obj.fontFamily ?? '');
    writer.writeString(obj.fontPackage ?? '');
    writer.writeBool(obj.matchTextDirection);
  }
}

class DateTimeAdapter extends TypeAdapter<DateTime> {
  @override
  final int typeId = 202;

  @override
  DateTime read(BinaryReader reader) {
    return DateTime.fromMillisecondsSinceEpoch(reader.readInt());
  }

  @override
  void write(BinaryWriter writer, DateTime obj) {
    writer.writeInt(obj.millisecondsSinceEpoch);
  }
}
