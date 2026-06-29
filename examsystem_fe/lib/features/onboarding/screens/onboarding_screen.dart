import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../widgets/decorative_background.dart';
import '../widgets/wave_bottom_section.dart';

// ════════════════════════════════════════════════════════════════════════════
// OnboardingScreen — Màn hình giới thiệu FPT ExamHub.
//
// Chuyển đổi 100% từ Splash & Onboarding.txt (HTML).
//
// Cấu trúc theo HTML:
//   <main> (full-screen)
//     ├── Decorative Background (4 circles/dots nổi)
//     ├── <header> Logo FPT + status bar
//     ├── Content area (illustration + title + subtitle + dots)
//     └── Wave bottom (Get Started + Log in)
//
// KHÔNG gọi API nào — màn hình hoàn toàn tĩnh.
// Navigate: "Get Started" và "Log in" → /login
// ════════════════════════════════════════════════════════════════════════════
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  // Trang onboarding hiện tại (dot indicator).
  // HTML chỉ có 1 trang visible nhưng có dots → implement đủ để UI đúng.
  int _currentPage = 0;

  // Nội dung các trang onboarding (slide).
  // Lấy từ HTML: tiêu đề và mô tả phần nội dung chính.
  static const List<_OnboardingContent> _pages = [
    _OnboardingContent(
      icon: Icons.quiz_rounded,
      title: 'Thi trực tuyến\nmọi lúc mọi nơi',
      subtitle:
          'Hệ thống thi online hiện đại của FPT University.\nTruy cập đề thi, làm bài và xem kết quả ngay lập tức.',
    ),
    _OnboardingContent(
      icon: Icons.analytics_rounded,
      title: 'Theo dõi\nkết quả tức thì',
      subtitle:
          'Xem điểm số, phân tích câu trả lời và\nthống kê kết quả sau mỗi bài thi.',
    ),
    _OnboardingContent(
      icon: Icons.security_rounded,
      title: 'An toàn\nvà bảo mật',
      subtitle:
          'Hệ thống xác thực JWT đảm bảo\nbảo mật tuyệt đối cho mọi kỳ thi.',
    ),
  ];

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Đặt status bar style: dark icons trên nền trắng.
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // icon đen trên nền trắng
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nền trắng — đồng bộ với background: #ffffff trong HTML.
      backgroundColor: Colors.white,

      // Mở rộng body sau status bar để overlay decorative elements.
      extendBodyBehindAppBar: true,

      body: Stack(
        children: [
          // ── Layer 1: Decorative Background (z-index: 0 trong HTML) ─────────
          // Pointer events: none (không chặn touch events).
          const Positioned.fill(
            child: IgnorePointer(
              child: DecorativeBackground(),
            ),
          ),

          // ── Layer 2: Nội dung chính ──────────────────────────────────────
          SafeArea(
            bottom: false, // Wave bottom xử lý padding riêng
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header: Logo FPT University ─────────────────────────────
                // HTML: <header class="w-full px-md pt-gutter">
                // px-md = 16px, pt-gutter = 12px
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, // px-md: 16px
                    vertical: 12,   // pt-gutter: 12px
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo FPT bên trái
                      _FptLogoSmall(),

                      // Skip button (tùy chọn — nút bỏ qua nhanh)
                      if (_currentPage < _pages.length - 1)
                        TextButton(
                          onPressed: () => context.go(AppRouter.login),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF485F84), // secondary
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Content: PageView (illustration + title + subtitle) ─────
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return _OnboardingPageContent(
                        content: _pages[index],
                        isActive: index == _currentPage,
                      );
                    },
                  ),
                ),

                // ── Dot Indicator ────────────────────────────────────────────
                // HTML có dots nhưng không rõ số lượng — implement đủ 3 trang.
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _DotIndicator(
                    count: _pages.length,
                    currentIndex: _currentPage,
                  ),
                ),

                // ── Wave Bottom: Buttons ─────────────────────────────────────
                // HTML: .wave-shape + buttons bên trong
                const WaveBottomSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _FptLogoSmall — Logo FPT nhỏ ở header (w-8 h-8 = 32x32px trong HTML).
// ════════════════════════════════════════════════════════════════════════════
class _FptLogoSmall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32, // w-8 = 2rem = 32px
      height: 32, // h-8 = 2rem = 32px
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF15A22),
            Color(0xFFD14307),
          ],
        ),
      ),
      child: const Center(
        child: Text(
          'F',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _OnboardingContent — Data model cho mỗi trang onboarding.
// ════════════════════════════════════════════════════════════════════════════
class _OnboardingContent {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingContent({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

// ════════════════════════════════════════════════════════════════════════════
// _OnboardingPageContent — Nội dung một trang: illustration + title + subtitle.
//
// HTML: phần giữa màn hình với illustration và text.
// ════════════════════════════════════════════════════════════════════════════
class _OnboardingPageContent extends StatelessWidget {
  final _OnboardingContent content;
  final bool isActive;

  const _OnboardingPageContent({
    required this.content,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy chiều cao màn hình để tối ưu kích thước ảnh minh họa và khoảng cách
    final double screenHeight = MediaQuery.of(context).size.height;
    
    // Nếu màn hình quá ngắn (ví dụ dưới 680px), tự động thu nhỏ illustration xuống 130px, bình thường là 200px
    final double illustrationSize = screenHeight < 680 ? 130.0 : 200.0;
    final double spacingHeight = screenHeight < 680 ? 20.0 : 40.0;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Illustration ─────────────────────────────────────────────────
              // HTML có illustration ảnh ở giữa — dùng icon lớn thay thế
              // vì phần illustration trong HTML bị truncate.
              AnimatedOpacity(
                opacity: isActive ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  width: illustrationSize,
                  height: illustrationSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF15A22).withValues(alpha: 0.08),
                  ),
                  child: Center(
                    child: Container(
                      width: illustrationSize * 0.7,
                      height: illustrationSize * 0.7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF15A22).withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        content.icon,
                        size: illustrationSize * 0.36,
                        color: const Color(0xFFF15A22), // primary: #F15A22
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: spacingHeight),

              // ── Title ────────────────────────────────────────────────────────
              // HTML: display-lg-mobile: 28px, fontWeight 700, lineHeight 36px
              AnimatedOpacity(
                opacity: isActive ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Text(
                  content.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,     // display-lg-mobile: 28px
                    fontWeight: FontWeight.w700,
                    height: 36 / 28, // lineHeight: 36px / fontSize: 28px
                    color: Color(0xFF0B1C30), // on-background: #0b1c30
                    letterSpacing: -0.56,    // -0.02em
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Subtitle ─────────────────────────────────────────────────────
              // HTML: body-lg: 16px, fontWeight 400, lineHeight 24px
              AnimatedOpacity(
                opacity: isActive ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Text(
                  content.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,     // body-lg: 16px
                    fontWeight: FontWeight.w400,
                    height: 24 / 16, // lineHeight: 24px
                    color: Color(0xFF485F84), // secondary: #485f84
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _DotIndicator — Chấm tròn chỉ trang hiện tại (page indicator).
//
// Thiết kế:
//   - Dot active: rộng hơn (pill shape), màu primary #F15A22
//   - Dot inactive: hình tròn nhỏ, màu xám mờ
// ════════════════════════════════════════════════════════════════════════════
class _DotIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _DotIndicator({
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final bool isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,  // Active dot: pill shape (wider)
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? const Color(0xFFF15A22)                           // primary: #F15A22
                : const Color(0xFFF15A22).withValues(alpha: 0.25), // mờ khi inactive
          ),
        );
      }),
    );
  }
}
