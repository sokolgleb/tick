class TimeEntry {
  final String id;
  final String activityId;
  final String userId;
  final double value; // time in minutes
  final double countValue; // count/repetitions
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  const TimeEntry({
    required this.id,
    required this.activityId,
    required this.userId,
    required this.value,
    required this.countValue,
    required this.date,
    this.note,
    required this.createdAt,
  });

  int get durationMinutes => value.toInt();

  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'] as String,
      activityId: json['activity_id'] as String,
      userId: json['user_id'] as String,
      value: _parseNum(json['value']),
      countValue: _parseNum(json['count_value']),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_id': activityId,
      'user_id': userId,
      'value': value,
      'count_value': countValue,
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      if (note != null) 'note': note,
    };
  }

  static double _parseNum(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '0') ?? 0;
  }
}
