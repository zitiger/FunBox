import 'package:flutter/material.dart';

class AppTheme {
  static const Color backgroundTop = Color(0xFF09164C);
  static const Color backgroundBottom = Color(0xFF0D1441);
  static const Color surface = Color(0xFF1A225D);
  static const Color surfaceAlt = Color(0xFF242D6E);
  static const Color navSurface = Color(0xFF151D53);
  static const Color accent = Color(0xFFFFA534);
  static const Color accentSoft = Color(0xFFFFC65C);
  static const Color textPrimary = Color(0xFFF7F4F0);
  static const Color textSecondary = Color(0xFFB5B8D6);
  static const Color success = Color(0xFF2BD0A5);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundBottom,
      fontFamily: 'sans-serif',
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: accent,
        secondary: accentSoft,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
