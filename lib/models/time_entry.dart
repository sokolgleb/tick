class TimeEntry {
  final String id;
  final String activityId;
  final String userId;
  final int durationMinutes;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  const TimeEntry({
    required this.id,
    required this.activityId,
    required this.userId,
    required this.durationMinutes,
    required this.date,
    this.note,
    required this.createdAt,
  });

  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'] as String,
      activityId: json['activity_id'] as String,
      userId: json['user_id'] as String,
      durationMinutes: json['duration_minutes'] as int,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_id': activityId,
      'user_id': userId,
      'duration_minutes': durationMinutes,
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      if (note != null) 'note': note,
    };
  }
}
