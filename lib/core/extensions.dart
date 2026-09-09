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

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}
