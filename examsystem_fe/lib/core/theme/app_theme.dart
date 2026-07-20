import 'package:flutter/material.dart';

/// Theme chung cho toàn bộ app.
/// Chỉnh màu / font ở đây — không ai tự đặt màu inline trong Widget.
class AppTheme {
  // ── Color Palette ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFD14307); // FPT Orange / Primary (Match HTML #d14307)
  static const Color secondary = Color(0xFF1D3557); // FPT Navy / Secondary (Match HTML #1D3557)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFBA1A1A); // Match HTML error color
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF15A22); // FPT Orange
  static const Color navy = Color(0xFF0B1C30); // Match HTML on-background/on-surface
  static const Color lightBg = Color(0xFFF8F9FF); // Match HTML background #f8f9ff
  static const Color border = Color(0xFFE2E8F0);
  static const Color textMuted = Color(0xFF5A4139); // Match HTML on-surface-variant
  static const Color textPrimary = Color(0xFF0B1C30);
  static const Color textSecondary = Color(0xFF5A4139);


  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
        hintStyle: const TextStyle(color: textSecondary),
      ),

      // Text
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: textPrimary),
        bodySmall: TextStyle(color: textSecondary),
      ),
    );
  }
}
