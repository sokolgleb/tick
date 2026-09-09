import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/preferences.dart';
import '../repositories/preferences_repository.dart';
import 'auth_provider.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in ProviderScope'),
);

final appPreferencesProvider = Provider<AppPreferences>(
  (ref) => AppPreferences(ref.watch(sharedPreferencesProvider)),
);

final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => PreferencesRepository(ref.watch(supabaseClientProvider)),
);

// Theme
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) {
    final prefs = ref.watch(appPreferencesProvider);
    return ThemeModeNotifier(prefs, ref.read(preferencesRepositoryProvider));
  },
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final AppPreferences _prefs;
  final PreferencesRepository _repo;

  ThemeModeNotifier(this._prefs, this._repo) : super(_prefs.themeMode);

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await _prefs.setThemeMode(mode);
    await _repo.updatePreferences(theme: mode.name);
  }
}

// Locale
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>(
  (ref) {
    final prefs = ref.watch(appPreferencesProvider);
    return LocaleNotifier(prefs, ref.read(preferencesRepositoryProvider));
  },
);

class LocaleNotifier extends StateNotifier<Locale?> {
  final AppPreferences _prefs;
  final PreferencesRepository _repo;

  LocaleNotifier(this._prefs, this._repo) : super(_prefs.locale);

  Future<void> set(Locale? locale) async {
    state = locale;
    await _prefs.setLocale(locale);
    await _repo.updatePreferences(locale: locale?.languageCode ?? 'system');
  }
}

// View mode
final viewModeProvider = StateNotifierProvider<ViewModeNotifier, ViewMode>(
  (ref) {
    final prefs = ref.watch(appPreferencesProvider);
    return ViewModeNotifier(prefs, ref.read(preferencesRepositoryProvider));
  },
);

class ViewModeNotifier extends StateNotifier<ViewMode> {
  final AppPreferences _prefs;
  final PreferencesRepository _repo;

  ViewModeNotifier(this._prefs, this._repo) : super(_prefs.viewMode);

  Future<void> set(ViewMode mode) async {
    state = mode;
    await _prefs.setViewMode(mode);
    await _repo.updatePreferences(viewMode: mode.name);
  }
}

// Sync preferences from Supabase on login
final syncPreferencesProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(preferencesRepositoryProvider);
  final prefs = ref.watch(appPreferencesProvider);

  try {
    final remote = await repo.getPreferences();
    if (remote != null) {
      final theme = switch (remote['theme'] as String?) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
      await prefs.setThemeMode(theme);

      final localeCode = remote['locale'] as String?;
      if (localeCode != null && localeCode != 'system') {
        await prefs.setLocale(Locale(localeCode));
      }

      final viewModeStr = remote['view_mode'] as String?;
      if (viewModeStr == 'grid') {
        await prefs.setViewMode(ViewMode.grid);
      }
    }
  } catch (_) {
    // Ignore sync errors — local prefs are the fallback
  }
});
