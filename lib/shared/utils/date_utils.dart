import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility functions for date and time formatting.
class DateUtils {
  DateUtils._();

  /// Formats a DateTime to "d/M" format (e.g., "29/3").
  static String formatDateShort(DateTime date) {
    return DateFormat('d/M').format(date);
  }

  /// Formats a DateTime to "EEE d/M" format with day of week in Spanish (e.g., "sáb 29/3").
  static String formatDateWithDay(DateTime date) {
    return DateFormat('E d/M', 'es_ES').format(date);
  }

  /// Formats a DateTime to full day name in Spanish (e.g., "sábado").
  static String getDayName(DateTime date) {
    return DateFormat('EEEE', 'es_ES').format(date);
  }

  /// Formats a TimeOfDay to "HH:mm" format (e.g., "17:00").
  static String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Formats a TimeOfDay to human-readable format (e.g., "17:00").
  static String formatTimeOfDay(TimeOfDay time) {
    return formatTime(time);
  }

  /// Parses a time string in "HH:mm" format to TimeOfDay.
  static TimeOfDay? parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }
}
