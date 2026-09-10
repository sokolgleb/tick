import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/entry_sort.dart';
import '../models/time_entry.dart';

class TimeEntriesRepository {
  final SupabaseClient _client;

  TimeEntriesRepository(this._client);

  String get _userId => _client.auth.currentUser!.id;

  Future<List<TimeEntry>> getEntries(
    String activityId, {
    DateTime? from,
    DateTime? to,
    EntrySort sort = EntrySort.dateDesc,
  }) async {
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

    final List<Map<String, dynamic>> data;
    switch (sort) {
      case EntrySort.dateDesc:
        data = await query.order('date', ascending: false).order('created_at', ascending: false);
      case EntrySort.dateAsc:
        data = await query.order('date').order('created_at');
      case EntrySort.valueDesc:
        data = await query.order('value', ascending: false);
      case EntrySort.valueAsc:
        data = await query.order('value');
    }

    return data.map((json) => TimeEntry.fromJson(json)).toList();
  }

  /// Returns totals per activity: {activityId: (time, count)}
  Future<Map<String, ({double time, double count})>> getTotals(DateTime from, DateTime to) async {
    final data = await _client
        .from('time_entries')
        .select('activity_id, value, count_value')
        .gte('date', _dateString(from))
        .lte('date', _dateString(to));

    final totals = <String, ({double time, double count})>{};
    for (final row in data) {
      final activityId = row['activity_id'] as String;
      final time = _parseNum(row['value']);
      final count = _parseNum(row['count_value']);
      final prev = totals[activityId];
      totals[activityId] = (
        time: (prev?.time ?? 0) + time,
        count: (prev?.count ?? 0) + count,
      );
    }
    return totals;
  }

  /// Returns totals for a single activity
  Future<({double time, double count})> getActivityTotal(
    String activityId,
    DateTime from,
    DateTime to,
  ) async {
    final data = await _client
        .from('time_entries')
        .select('value, count_value')
        .eq('activity_id', activityId)
        .gte('date', _dateString(from))
        .lte('date', _dateString(to));

    double time = 0;
    double count = 0;
    for (final row in data) {
      time += _parseNum(row['value']);
      count += _parseNum(row['count_value']);
    }
    return (time: time, count: count);
  }

  /// Recursive subtree total via RPC
  Future<({double timeTotal, double countTotal})> getSubtreeTotal(
    String activityId,
    DateTime from,
    DateTime to,
  ) async {
    final data = await _client.rpc('get_activity_subtree_total', params: {
      'p_activity_id': activityId,
      'p_from': _dateString(from),
      'p_to': _dateString(to),
    });

    if (data is List && data.isNotEmpty) {
      final row = data[0] as Map<String, dynamic>;
      return (
        timeTotal: _parseNum(row['time_total']),
        countTotal: _parseNum(row['count_total']),
      );
    }
    return (timeTotal: 0.0, countTotal: 0.0);
  }

  Future<TimeEntry> addEntry({
    required String activityId,
    double timeMinutes = 0,
    double countValue = 0,
    DateTime? date,
    String? note,
  }) async {
    final row = <String, dynamic>{
      'activity_id': activityId,
      'user_id': _userId,
      'value': timeMinutes,
      'count_value': countValue,
      'date': _dateString(date ?? DateTime.now()),
      if (note != null) 'note': note,
    };

    if (timeMinutes > 0) {
      row['duration_minutes'] = timeMinutes.toInt();
    }

    final data = await _client.from('time_entries').insert(row).select().single();
    return TimeEntry.fromJson(data);
  }

  Future<TimeEntry> updateEntry(
    String id, {
    double? timeMinutes,
    double? countValue,
  }) async {
    final updates = <String, dynamic>{};
    if (timeMinutes != null) {
      updates['value'] = timeMinutes;
      updates['duration_minutes'] = timeMinutes.toInt();
    }
    if (countValue != null) updates['count_value'] = countValue;
    final data = await _client.from('time_entries').update(updates).eq('id', id).select().single();
    return TimeEntry.fromJson(data);
  }

  Future<void> deleteEntry(String id) async {
    await _client.from('time_entries').delete().eq('id', id);
  }

  String _dateString(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  double _parseNum(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '0') ?? 0;
  }
}
