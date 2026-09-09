import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity.dart';

class ActivitiesRepository {
  final SupabaseClient _client;

  ActivitiesRepository(this._client);

  String get _userId => _client.auth.currentUser!.id;

  Future<List<Activity>> getActivities() async {
    final data = await _client
        .from('activities')
        .select()
        .eq('archived', false)
        .order('position')
        .order('created_at');
    return data.map((json) => Activity.fromJson(json)).toList();
  }

  Future<Activity> create({required String name, required String color}) async {
    final data = await _client.from('activities').insert({
      'user_id': _userId,
      'name': name,
      'color': color,
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
