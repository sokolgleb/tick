import 'package:flutter/material.dart';
import 'package:tick/l10n/app_localizations.dart';

extension DurationFormatting on int {
  /// Formats minutes into human-readable string: "2h 15m", "45m", "0m"
  String toTimeString() {
    if (this <= 0) return '0m';
    final hours = this ~/ 60;
    final minutes = this % 60;
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    return '${minutes}m';
  }

  /// Locale-aware time string using l10n
  String toLocalizedTimeString(BuildContext context) {
    final l10n = S.of(context)!;
    if (this <= 0) return l10n.zeroMinutes;
    final hours = this ~/ 60;
    final minutes = this % 60;
    if (hours > 0 && minutes > 0) return l10n.hoursMinutes(hours, minutes);
    if (hours > 0) return l10n.hoursOnly(hours);
    return l10n.minutesOnly(minutes);
  }
}

extension DoubleFormatting on double {
  /// Format value based on tracking type
  String toValueString({bool isCount = false}) {
    if (isCount) {
      // Remove trailing zeros for count
      final intVal = toInt();
      return intVal == this ? '${intVal}x' : '${toStringAsFixed(1)}x';
    }
    return toInt().toTimeString();
  }

  String toLocalizedValueString(BuildContext context, {bool isCount = false}) {
    if (isCount) {
      final l10n = S.of(context)!;
      final intVal = toInt();
      final display = intVal == this ? '$intVal' : toStringAsFixed(1);
      return l10n.countFormat(display);
    }
    return toInt().toLocalizedTimeString(context);
  }
}

extension DateHelpers on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get startOfWeek {
    final diff = weekday - DateTime.monday;
    return subtract(Duration(days: diff)).startOfDay;
  }

  DateTime get startOfMonth => DateTime(year, month, 1);

  DateTime get startOfYear => DateTime(year, 1, 1);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  String toDateString() {
    final now = DateTime.now();
    if (isSameDay(now)) return 'Today';
    if (isSameDay(now.subtract(const Duration(days: 1)))) return 'Yesterday';
    return '${_monthNames[month - 1]} $day';
  }

  String toLocalizedDateString(BuildContext context) {
    final l10n = S.of(context)!;
    final now = DateTime.now();
    if (isSameDay(now)) return l10n.today;
    if (isSameDay(now.subtract(const Duration(days: 1)))) return l10n.yesterday;
    return '${_monthNames[month - 1]} $day';
  }

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}

Color parseHexColor(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 7) buffer.write('FF');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

String colorToHex(Color color) {
  return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}

/// Formats combined time + count into a single display string.
/// Shows "2h 15m + 12x" if both, or just one, or "0m" if neither.
String formatDualValue(BuildContext context, double time, double count) {
  final parts = <String>[];
  if (time > 0) parts.add(time.toLocalizedValueString(context, isCount: false));
  if (count > 0) parts.add(count.toLocalizedValueString(context, isCount: true));
  if (parts.isEmpty) return 0.toLocalizedTimeString(context);
  return parts.join(' + ');
}
