import 'package:flutter/material.dart';

class SkiTrackerTheme {
  static const _primary = Color(0xFF4FC3F7);
  static const _accent = Color(0xFFFF7043);
  static const _background = Color(0xFF121212);
  static const _surface = Color(0xFF1E1E1E);

  static final dark = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: _primary,
      secondary: _accent,
      surface: _surface,
    ),
    scaffoldBackgroundColor: _background,
    appBarTheme: const AppBarTheme(
      backgroundColor: _surface,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: _surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    useMaterial3: true,
  );
}
