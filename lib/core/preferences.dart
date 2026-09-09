import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ViewMode { list, grid }

class AppPreferences {
  final SharedPreferences _prefs;

  AppPreferences(this._prefs);

  // Theme
  ThemeMode get themeMode {
    final value = _prefs.getString('theme_mode') ?? 'system';
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString('theme_mode', value);
  }

  // Locale
  Locale? get locale {
    final code = _prefs.getString('locale');
    if (code == null || code == 'system') return null;
    return Locale(code);
  }

  Future<void> setLocale(Locale? locale) async {
    await _prefs.setString('locale', locale?.languageCode ?? 'system');
  }

  // View mode
  ViewMode get viewMode {
    final value = _prefs.getString('view_mode') ?? 'list';
    return value == 'grid' ? ViewMode.grid : ViewMode.list;
  }

  Future<void> setViewMode(ViewMode mode) async {
    await _prefs.setString('view_mode', mode == ViewMode.grid ? 'grid' : 'list');
  }
}
