import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/utils/storage_manager.dart';

// ════════════════════════════════════════════════════════════════════════════
// SplashScreen — Màn hình khởi động của FPT ExamHub.
//
// Nhiệm vụ:
//   1. Hiển thị logo FPT ExamHub với animation fade-in.
//   2. Delay 2.5 giây (giống pattern mobile app thông thường).
//   3. Kiểm tra token cục bộ (StorageManager — không gọi API).
//   4. Navigate:
//      - Đã đăng nhập → /exams
//      - Chưa đăng nhập → /onboarding
//
// KHÔNG gọi API nào từ màn hình này.
// KHÔNG fake dữ liệu.
// ════════════════════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller cho hiệu ứng fade-in logo.
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Cấu hình animation fade-in: 0.0 → 1.0 trong 800ms.
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Bắt đầu animation ngay khi màn hình mount.
    _fadeController.forward();

    // Sau 2.5 giây → kiểm tra trạng thái đăng nhập và navigate.
    _navigateAfterDelay();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Delay 2.5 giây rồi kiểm tra token cục bộ và navigate.
  ///
  /// Logic điều hướng:
  ///   - Đã đăng nhập (có accessToken) → /exams (trang chủ)
  ///   - Chưa đăng nhập → /onboarding
  ///
  /// KHÔNG gọi API — chỉ đọc SharedPreferences qua StorageManager.
  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    // Kiểm tra widget còn mounted sau khi delay không (tránh navigate khi đã dispose).
    if (!mounted) return;

    // Kiểm tra trạng thái đăng nhập từ bộ nhớ cục bộ.
    final bool isLoggedIn = await StorageManager.isLoggedIn();

    // Kiểm tra lại mounted sau await.
    if (!mounted) return;

    if (isLoggedIn) {
      // Đã đăng nhập → thẳng vào trang danh sách đề thi.
      context.go(AppRouter.examList);
    } else {
      // Chưa đăng nhập → hiển thị Onboarding.
      context.go(AppRouter.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nền trắng — đồng bộ với background: #ffffff trong HTML.
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo FPT ExamHub ────────────────────────────────────────
                // Dùng widget thay vì ảnh vì logo trong HTML là base64 rất dài.
                // Design: hình tròn màu FPT Orange chứa icon graduation cap.
                _FptLogoWidget(),

                const SizedBox(height: 24),

                // ── Tên ứng dụng ────────────────────────────────────────────
                Text(
                  'FPT ExamHub',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B1C30), // on-background: #0b1c30
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 8),

                // ── Tagline ─────────────────────────────────────────────────
                Text(
                  'Hệ thống thi trực tuyến FPT',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF485F84), // secondary: #485f84
                  ),
                ),

                const SizedBox(height: 48),

                // ── Loading indicator ───────────────────────────────────────
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFF15A22), // primary: #F15A22
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _FptLogoWidget — Logo FPT ExamHub được vẽ bằng Flutter Widget.
//
// Thay thế cho ảnh base64 trong HTML (quá dài để nhúng).
// Design: hình tròn cam FPT (#F15A22) chứa text "FPT" và icon.
// ════════════════════════════════════════════════════════════════════════════
class _FptLogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF15A22), // FPT Orange
            Color(0xFFD14307), // primary-container: #d14307
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF15A22).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 36,
          ),
          SizedBox(height: 2),
          Text(
            'FPT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
