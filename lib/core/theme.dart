import 'package:flutter/material.dart';

class TickTheme {
  static const _textColor = Color(0xFF1A1A1A);
  static const _secondaryTextColor = Color(0xFF6B7280);
  static const _dividerColor = Color(0xFFF3F4F6);
  static const _backgroundColor = Colors.white;

  static const activityColors = [
    Color(0xFF000000),
    Color(0xFFEF4444),
    Color(0xFFF97316),
    Color(0xFFEAB308),
    Color(0xFF22C55E),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        surface: _backgroundColor,
        onSurface: _textColor,
        primary: _textColor,
        onPrimary: _backgroundColor,
      ),
      scaffoldBackgroundColor: _backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: _backgroundColor,
        foregroundColor: _textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: _textColor,
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _dividerColor,
        thickness: 1,
        space: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: _textColor),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _textColor),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: _textColor),
        bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: _secondaryTextColor),
        bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: _secondaryTextColor),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _textColor,
          foregroundColor: _backgroundColor,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _textColor,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: _dividerColor),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _textColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
