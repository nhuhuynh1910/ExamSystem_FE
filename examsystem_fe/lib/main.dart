import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/routes/app_router.dart';

// ════════════════════════════════════════════════════════════════════════════
// main.dart — Điểm khởi đầu của ứng dụng ExamSystem FE.
//
// Nhiệm vụ của file này:
//   1. Khởi tạo Flutter binding (bắt buộc trước khi dùng plugin như SharedPreferences).
//   2. Pre-load SharedPreferences để đảm bảo plugin sẵn sàng ngay từ đầu.
//   3. Khởi chạy app với cấu hình GoRouter từ AppRouter.
//
// KHÔNG thêm logic nghiệp vụ hay Widget UI vào file này.
// KHÔNG định nghĩa route ở đây — tất cả route đã tập trung tại AppRouter.
// ════════════════════════════════════════════════════════════════════════════
Future<void> main() async {
  // Bước 1: Khởi tạo Flutter binding.
  // BẮT BUỘC gọi trước khi sử dụng bất kỳ plugin nào (shared_preferences, dio, v.v.).
  // Nếu bỏ dòng này, SharedPreferences.getInstance() sẽ bị lỗi ngay khi app khởi động.
  WidgetsFlutterBinding.ensureInitialized();

  // Bước 2: Pre-load SharedPreferences instance.
  // Đảm bảo plugin đã sẵn sàng trước khi app render widget đầu tiên.
  // Điều này giúp AppRouter.router đọc token ngay lập tức khi GoRouter
  // kiểm tra guard redirect mà không bị delay.
  await SharedPreferences.getInstance();

  // Bước 3: Khởi chạy app.
  runApp(const ExamSystemApp());
}

/// Root Widget của ứng dụng.
///
/// Sử dụng MaterialApp.router để tích hợp GoRouter từ AppRouter.
/// Không dùng MaterialApp thông thường vì sẽ xung đột với GoRouter.
class ExamSystemApp extends StatelessWidget {
  const ExamSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // ── Thông tin app ──────────────────────────────────────────────────────
      title: 'FPT ExamHub',

      // ── Ẩn badge "DEBUG" ở góc trên phải khi chạy debug mode ──────────────
      debugShowCheckedModeBanner: false,

      // ── Theme — màu sắc và font đồng bộ với thiết kế HTML ────────────────
      // Primary: #F15A22 (FPT Orange) — lấy từ Tailwind config trong HTML.
      // Font: Inter — đồng bộ với fontFamily trong HTML.
      theme: _buildTheme(),

      // ── Kết nối với GoRouter từ AppRouter ─────────────────────────────────
      // routerConfig thay thế hoàn toàn cho home/initialRoute của MaterialApp.
      // GoRouter sẽ tự quyết định màn hình nào hiển thị đầu tiên
      // dựa trên initialLocation và kết quả của hàm guard _guardRedirect.
      routerConfig: AppRouter.router,
    );
  }

  /// Xây dựng ThemeData đồng bộ với thiết kế HTML/Figma.
  ///
  /// Màu sắc lấy từ Tailwind config trong Splash & Onboarding.txt:
  ///   primary: #F15A22
  ///   background: #ffffff
  ///   on-background: #0b1c30
  ///   surface-container: #e5eeff
  ///   secondary: #485f84
  ThemeData _buildTheme() {
    // Dùng ColorScheme.fromSeed với seedColor là FPT Orange.
    // Material 3 tự tính toán toàn bộ bảng màu từ seed color.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFF15A22), // FPT Orange — primary từ HTML
      brightness: Brightness.light,
    ).copyWith(
      // Override các màu cần khớp chính xác với HTML design:
      primary: const Color(0xFFF15A22),        // primary: #F15A22
      surface: const Color(0xFFF8F9FF),         // surface: #f8f9ff
      surfaceContainerLowest: Colors.white,     // surface-container-lowest: #ffffff
      onSurface: const Color(0xFF0B1C30),       // on-surface: #0b1c30
      secondary: const Color(0xFF485F84),       // secondary: #485f84
      error: const Color(0xFFBA1A1A),           // error: #ba1a1a
      outline: const Color(0xFF8E7067),         // outline: #8e7067
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // Font Inter — đồng bộ với fontFamily trong HTML design.
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme,
      ),

      // Scaffold background: #ffffff (background từ HTML).
      scaffoldBackgroundColor: Colors.white,
    );
  }
}
