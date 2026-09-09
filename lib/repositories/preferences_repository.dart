import 'package:supabase_flutter/supabase_flutter.dart';

class PreferencesRepository {
  final SupabaseClient _client;

  PreferencesRepository(this._client);

  String get _userId => _client.auth.currentUser!.id;

  Future<Map<String, dynamic>?> getPreferences() async {
    final data = await _client
        .from('user_preferences')
        .select()
        .eq('user_id', _userId)
        .maybeSingle();
    return data;
  }

  Future<void> updatePreferences({
    String? theme,
    String? locale,
    String? viewMode,
  }) async {
    final updates = <String, dynamic>{};
    if (theme != null) updates['theme'] = theme;
    if (locale != null) updates['locale'] = locale;
    if (viewMode != null) updates['view_mode'] = viewMode;

    if (updates.isEmpty) return;

    await _client.from('user_preferences').upsert({
      'user_id': _userId,
      ...updates,
    }, onConflict: 'user_id');
  }
}
