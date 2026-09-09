import 'package:flutter/material.dart';

class TickTheme {
  // Light palette
  static const _lightBg = Color(0xFFFFFFFF);
  static const _lightSurface = Color(0xFFFAFAFA);
  static const _lightText = Color(0xFF111111);
  static const _lightSecondary = Color(0xFF888888);
  static const _lightBorder = Color(0xFFEEEEEE);

  // Dark palette
  static const _darkBg = Color(0xFF0F0F0F);
  static const _darkSurface = Color(0xFF1A1A1A);
  static const _darkText = Color(0xFFF0F0F0);
  static const _darkSecondary = Color(0xFF777777);
  static const _darkBorder = Color(0xFF2A2A2A);

  static ThemeData get light => _build(
        brightness: Brightness.light,
        bg: _lightBg,
        surface: _lightSurface,
        text: _lightText,
        secondary: _lightSecondary,
        border: _lightBorder,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        bg: _darkBg,
        surface: _darkSurface,
        text: _darkText,
        secondary: _darkSecondary,
        border: _darkBorder,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color text,
    required Color secondary,
    required Color border,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: text,
        onPrimary: bg,
        secondary: secondary,
        onSecondary: bg,
        surface: bg,
        onSurface: text,
        error: const Color(0xFFDC2626),
        onError: Colors.white,
        surfaceContainerHighest: surface,
        outline: border,
      ),
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 0,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: text),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: text),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: text),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: secondary),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: secondary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: text),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: text,
          foregroundColor: bg,
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: border),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: text,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: UnderlineInputBorder(borderSide: BorderSide(color: border)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: border)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: text)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        hintStyle: TextStyle(color: secondary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: text,
        labelStyle: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.w500),
        secondaryLabelStyle: TextStyle(color: bg, fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: border),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ),
    );
  }
}
