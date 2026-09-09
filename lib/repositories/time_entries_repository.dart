import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/time_entry.dart';

class TimeEntriesRepository {
  final SupabaseClient _client;

  TimeEntriesRepository(this._client);

  String get _userId => _client.auth.currentUser!.id;

  Future<List<TimeEntry>> getEntries(String activityId, {DateTime? from, DateTime? to}) async {
    var query = _client
        .from('time_entries')
        .select()
        .eq('activity_id', activityId);

    if (from != null) {
      query = query.gte('date', _dateString(from));
    }
    if (to != null) {
      query = query.lte('date', _dateString(to));
    }

    final data = await query.order('date', ascending: false).order('created_at', ascending: false);
    return data.map((json) => TimeEntry.fromJson(json)).toList();
  }

  /// Returns total minutes per activity for a date range
  Future<Map<String, int>> getTotals(DateTime from, DateTime to) async {
    final data = await _client
        .from('time_entries')
        .select('activity_id, duration_minutes')
        .gte('date', _dateString(from))
        .lte('date', _dateString(to));

    final totals = <String, int>{};
    for (final row in data) {
      final activityId = row['activity_id'] as String;
      final minutes = row['duration_minutes'] as int;
      totals[activityId] = (totals[activityId] ?? 0) + minutes;
    }
    return totals;
  }

  /// Returns total minutes for a single activity in a date range
  Future<int> getActivityTotal(String activityId, DateTime from, DateTime to) async {
    final data = await _client
        .from('time_entries')
        .select('duration_minutes')
        .eq('activity_id', activityId)
        .gte('date', _dateString(from))
        .lte('date', _dateString(to));

    int total = 0;
    for (final row in data) {
      total += row['duration_minutes'] as int;
    }
    return total;
  }

  Future<TimeEntry> addEntry({
    required String activityId,
    required int durationMinutes,
    DateTime? date,
    String? note,
  }) async {
    final data = await _client.from('time_entries').insert({
      'activity_id': activityId,
      'user_id': _userId,
      'duration_minutes': durationMinutes,
      'date': _dateString(date ?? DateTime.now()),
      if (note != null) 'note': note,
    }).select().single();
    return TimeEntry.fromJson(data);
  }

  Future<void> deleteEntry(String id) async {
    await _client.from('time_entries').delete().eq('id', id);
  }

  String _dateString(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
