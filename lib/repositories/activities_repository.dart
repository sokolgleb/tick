import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity.dart';

class ActivitiesRepository {
  final SupabaseClient _client;

  ActivitiesRepository(this._client);

  String get _userId => _client.auth.currentUser!.id;

  /// Fetch top-level or child activities
  Future<List<Activity>> getActivities({String? parentId}) async {
    var query = _client
        .from('activities')
        .select()
        .eq('archived', false);

    if (parentId == null) {
      query = query.filter('parent_id', 'is', 'null');
    } else {
      query = query.eq('parent_id', parentId);
    }

    final data = await query.order('position').order('created_at');
    return data.map((json) => Activity.fromJson(json)).toList();
  }

  /// Get children of a specific activity
  Future<List<Activity>> getChildren(String parentId) async {
    return getActivities(parentId: parentId);
  }

  /// Get a single activity by ID
  Future<Activity?> getActivityById(String id) async {
    final data = await _client
        .from('activities')
        .select()
        .eq('id', id)
        .maybeSingle();
    return data != null ? Activity.fromJson(data) : null;
  }

  Future<Activity> create({
    required String name,
    required String color,
    String? parentId,
  }) async {
    final data = await _client.from('activities').insert({
      'user_id': _userId,
      'name': name,
      'color': color,
      if (parentId != null) 'parent_id': parentId,
    }).select().single();
    return Activity.fromJson(data);
  }

  Future<Activity> update(String id, {String? name, String? color, int? position, bool? archived}) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (color != null) updates['color'] = color;
    if (position != null) updates['position'] = position;
    if (archived != null) updates['archived'] = archived;

    final data = await _client
        .from('activities')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    return Activity.fromJson(data);
  }

  Future<void> delete(String id) async {
    await _client.from('activities').delete().eq('id', id);
  }
}
