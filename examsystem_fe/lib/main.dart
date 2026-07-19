import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

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
      title: 'ExamSystem',

      // ── Ẩn badge "DEBUG" ở góc trên phải khi chạy debug mode ──────────────
      debugShowCheckedModeBanner: false,

      // ── Cấu hình theme mặc định ────────────────────────────────────────────
      // Thành viên phụ trách theme sẽ bổ sung ThemeData đầy đủ vào lib/core/theme/
      // và import vào đây sau.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primary),
        useMaterial3: true,
        scaffoldBackgroundColor: AppTheme.lightBg,
      ),

      // ── Kết nối với GoRouter từ AppRouter ─────────────────────────────────
      // routerConfig thay thế hoàn toàn cho home/initialRoute của MaterialApp.
      // GoRouter sẽ tự quyết định màn hình nào hiển thị đầu tiên
      // dựa trên initialLocation và kết quả của hàm guard _guardRedirect.
      routerConfig: AppRouter.router,
    );
  }
}
