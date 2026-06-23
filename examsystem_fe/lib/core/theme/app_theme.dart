import 'package:flutter/material.dart';

/// Theme chung cho toàn bộ app.
/// Chỉnh màu / font ở đây — không ai tự đặt màu inline trong Widget.
class AppTheme {
  // ── Color Palette ──────────────────────────────────────────────────────────
  static const Color primary   = Color(0xFF4F46E5); // Indigo 600
  static const Color secondary = Color(0xFF7C3AED); // Violet 600
  static const Color surface   = Color(0xFF1E1E2E); // Dark background
  static const Color card      = Color(0xFF2A2A3C);
  static const Color error     = Color(0xFFEF4444);
  static const Color success   = Color(0xFF10B981);
  static const Color warning   = Color(0xFFF59E0B);
  static const Color textPrimary   = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary:   primary,
        secondary: secondary,
        surface:   surface,
        error:     error,
      ),
      scaffoldBackgroundColor: surface,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),

      // Card
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // TextField / InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle:  const TextStyle(color: textSecondary),
      ),

      // Text
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        titleLarge:   TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        bodyMedium:   TextStyle(color: textPrimary),
        bodySmall:    TextStyle(color: textSecondary),
      ),
    );
  }
}
