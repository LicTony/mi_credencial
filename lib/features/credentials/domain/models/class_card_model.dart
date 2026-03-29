import 'package:flutter/material.dart';

/// Represents a single class slot on the attendance card.
///
/// [date] - The date when the class was taken (null = empty slot)
/// [time] - The time slot chosen (17:00, 19:30, or 20:30)
class ClassSlot {
  final DateTime? date;
  final TimeOfDay? time;

  const ClassSlot({this.date, this.time});

  /// Whether this slot is marked with a class
  bool get isUsed => date != null && time != null;

  /// Creates a copy with optional new values
  ClassSlot copyWith({
    DateTime? date,
    TimeOfDay? time,
    bool clearDate = false,
    bool clearTime = false,
  }) {
    return ClassSlot(
      date: clearDate ? null : (date ?? this.date),
      time: clearTime ? null : (time ?? this.time),
    );
  }

  /// Creates an empty slot
  const ClassSlot.empty() : date = null, time = null;

  /// Creates a slot marked with the given date and time
  ClassSlot.marked({required DateTime date, required TimeOfDay time})
    : date = date,
      time = time;

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'date': date?.toIso8601String(),
      'time': time != null ? '${time!.hour}:${time!.minute}' : null,
    };
  }

  /// Create from JSON
  factory ClassSlot.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date'] as String?;
    final timeStr = json['time'] as String?;

    if (dateStr == null || timeStr == null) {
      return const ClassSlot.empty();
    }

    final date = DateTime.parse(dateStr);
    final timeParts = timeStr.split(':');
    final time = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    return ClassSlot.marked(date: date, time: time);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClassSlot && other.date == date && other.time == time;
  }

  @override
  int get hashCode => Object.hash(date, time);

  @override
  String toString() {
    if (isUsed) {
      return 'ClassSlot(date: $date, time: $time)';
    }
    return 'ClassSlot.empty()';
  }
}

/// Represents the complete attendance card model.
class ClassCardModel {
  final String studentName;
  final int totalClasses;
  final List<ClassSlot> slots;

  const ClassCardModel({
    required this.studentName,
    required this.totalClasses,
    required this.slots,
  });

  /// Number of marked slots
  int get usedCount => slots.where((slot) => slot.isUsed).length;

  /// Whether there are any marked slots
  bool get hasMarkedSlots => usedCount > 0;

  /// Number of remaining classes
  int get remainingCount => totalClasses - usedCount;

  /// Creates a copy with optional new values
  ClassCardModel copyWith({
    String? studentName,
    int? totalClasses,
    List<ClassSlot>? slots,
  }) {
    return ClassCardModel(
      studentName: studentName ?? this.studentName,
      totalClasses: totalClasses ?? this.totalClasses,
      slots: slots ?? this.slots,
    );
  }

  /// Creates a default empty card with 8 classes
  factory ClassCardModel.empty() {
    return ClassCardModel(
      studentName: '',
      totalClasses: 8,
      slots: List.generate(8, (_) => const ClassSlot.empty()),
    );
  }

  /// Creates a card with specified total classes
  factory ClassCardModel.withPack(int totalClasses) {
    return ClassCardModel(
      studentName: '',
      totalClasses: totalClasses,
      slots: List.generate(totalClasses, (_) => const ClassSlot.empty()),
    );
  }

  /// Convert to JSON for persistence (versioned format)
  Map<String, dynamic> toJson() {
    return {
      'version': 1,
      'studentName': studentName,
      'totalClasses': totalClasses,
      'slotsData': slots.map((slot) => slot.toJson()).toList(),
    };
  }

  /// Create from JSON with version handling for migrations
  factory ClassCardModel.fromJson(Map<String, dynamic> json) {
    final version = json['version'] as int? ?? 1;

    // Handle different versions here for future migrations
    if (version > 1) {
      // Future migration logic
    }

    final studentName = json['studentName'] as String? ?? '';
    final totalClasses = json['totalClasses'] as int? ?? 8;
    final slotsData = json['slotsData'] as List<dynamic>?;

    List<ClassSlot> slots;
    if (slotsData != null) {
      slots = slotsData
          .map((data) => ClassSlot.fromJson(data as Map<String, dynamic>))
          .toList();
    } else {
      slots = List.generate(totalClasses, (_) => const ClassSlot.empty());
    }

    // Ensure slots count matches totalClasses
    if (slots.length != totalClasses) {
      if (slots.length < totalClasses) {
        // Add missing slots
        slots.addAll(
          List.generate(
            totalClasses - slots.length,
            (_) => const ClassSlot.empty(),
          ),
        );
      } else {
        // Truncate extra slots
        slots = slots.sublist(0, totalClasses);
      }
    }

    return ClassCardModel(
      studentName: studentName,
      totalClasses: totalClasses,
      slots: slots,
    );
  }

  /// Validates the model data
  bool get isValid {
    return studentName.trim().isNotEmpty &&
        (totalClasses == 4 || totalClasses == 8 || totalClasses == 16) &&
        slots.length == totalClasses;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClassCardModel &&
        other.studentName == studentName &&
        other.totalClasses == totalClasses &&
        _listEquals(other.slots, slots);
  }

  @override
  int get hashCode =>
      Object.hash(studentName, totalClasses, Object.hashAll(slots));

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'ClassCardModel(studentName: $studentName, totalClasses: $totalClasses, usedCount: $usedCount)';
  }
}
