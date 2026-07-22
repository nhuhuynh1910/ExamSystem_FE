import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// AppTheme — Định nghĩa Light và Dark ThemeData cho toàn bộ app.
///
/// Sử dụng:
///   MaterialApp(
///     theme:      AppTheme.buildLight(primaryColor),
///     darkTheme:  AppTheme.buildDark(primaryColor),
///     themeMode:  notifier.themeMode,
///   )
/// ════════════════════════════════════════════════════════════════════════════
class AppTheme {
  // ── Color Palette (Light) ─────────────────────────────────────────────────
  static const Color primary      = Color(0xFFF15A22); // FPT Orange
  static const Color secondary    = Color(0xFF1D3557); // FPT Navy
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color card         = Color(0xFFFFFFFF);
  static const Color error        = Color(0xFFBA1A1A);
  static const Color success      = Color(0xFF10B981);
  static const Color warning      = Color(0xFFF15A22);
  static const Color navy         = Color(0xFF0B1C30);
  static const Color lightBg      = Color(0xFFF8F9FF);
  static const Color border       = Color(0xFFE2E8F0);
  static const Color textMuted    = Color(0xFF5A4139);
  static const Color textPrimary  = Color(0xFF0B1C30);
  static const Color textSecondary = Color(0xFF5A4139);

  // ── Color Palette (Dark) ──────────────────────────────────────────────────
  static const Color darkBg         = Color(0xFF121212);
  static const Color darkSurface    = Color(0xFF1E1E1E);
  static const Color darkCard       = Color(0xFF2C2C2C);
  static const Color darkBorder     = Color(0xFF3D3D3D);
  static const Color darkTextPrimary   = Color(0xFFE8EAED);
  static const Color darkTextSecondary = Color(0xFF9AA0A6);

  // ══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ══════════════════════════════════════════════════════════════════════════
  static ThemeData buildLight({Color seedColor = primary}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ).copyWith(
      primary:                  seedColor,
      surface:                  const Color(0xFFF8F9FF),
      surfaceContainerLowest:   Colors.white,
      onSurface:                const Color(0xFF0B1C30),
      secondary:                const Color(0xFF485F84),
      error:                    const Color(0xFFBA1A1A),
      outline:                  const Color(0xFF8E7067),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightBg,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),

      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: seedColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return const Color(0xFF9CA3AF);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return seedColor;
          return const Color(0xFFE5E7EB);
        }),
      ),

      dividerTheme: const DividerThemeData(color: Color(0xFFF3F4F6), thickness: 1),

      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.bold),
        titleLarge:   GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
        bodyMedium:   GoogleFonts.inter(color: textPrimary),
        bodySmall:    GoogleFonts.inter(color: textSecondary),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DARK THEME
  // ══════════════════════════════════════════════════════════════════════════
  static ThemeData buildDark({Color seedColor = primary}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ).copyWith(
      primary:   seedColor,
      surface:   darkSurface,
      onSurface: darkTextPrimary,
      secondary: const Color(0xFF93B4D4),
      error:     const Color(0xFFFF6B6B),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,

      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: darkTextPrimary),
      ),

      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: seedColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
        ),
        labelStyle: const TextStyle(color: darkTextSecondary),
        hintStyle:  const TextStyle(color: darkTextSecondary),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return const Color(0xFF6B7280);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return seedColor;
          return const Color(0xFF374151);
        }),
      ),

      dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1),

      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: darkTextPrimary, fontWeight: FontWeight.bold),
        titleLarge:   GoogleFonts.inter(color: darkTextPrimary, fontWeight: FontWeight.w600),
        bodyMedium:   GoogleFonts.inter(color: darkTextPrimary),
        bodySmall:    GoogleFonts.inter(color: darkTextSecondary),
      ),
    );
  }

  // ── Backward-compat getter (dùng trong code cũ nếu còn sót) ───────────────
  static ThemeData get darkTheme => buildDark();
}
