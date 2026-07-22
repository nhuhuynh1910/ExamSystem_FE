import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../data/google_auth_service.dart';
import 'widgets/google_account_tile.dart';
import 'widgets/google_footer_widget.dart';
import 'widgets/google_logo_widget.dart';

// ════════════════════════════════════════════════════════════════════════════
// GoogleAccountPickerScreen — Màn hình "Choose an account" kiểu Google.
//
// Chuyển đổi pixel-perfect từ loginlikegooogle.txt (HTML/Tailwind).
//
// Layout (từ HTML):
//   ┌─────────────────────────────────┐
//   │  ← Back        Sign in         │  ← header (sticky top)
//   │                                 │
//   │       [Google Logo 64x64]       │  ← Google branding
//   │     "Choose an account"         │
//   │  "to continue to FPT ExamHub"   │
//   │                                 │
//   │  ┌─────────────────────────┐    │
//   │  │ 🔵 Nguyen Van A        │    │  ← account tile 1
//   │  │    nguyenvana@fpt...    │    │
//   │  └─────────────────────────┘    │
//   │  ┌─────────────────────────┐    │
//   │  │ L  Le Thi B             │    │  ← account tile 2
//   │  │    lethib.student@...   │    │
//   │  └─────────────────────────┘    │
//   │  ┌─────────────────────────┐    │
//   │  │ +  Add another account  │    │  ← add account button
//   │  └─────────────────────────┘    │
//   │                                 │
//   │  "To continue, Google will..."  │  ← footer (mt-auto)
//   │  Privacy Policy · Terms of...   │
//   └─────────────────────────────────┘
//
// Animations (từ CSS):
//   - fadeUp: opacity 0→1, translateY 10px→0, 0.4s ease-out
//   - stagger: delay 0.1s, 0.2s, 0.3s cho mỗi section
// ════════════════════════════════════════════════════════════════════════════

/// Model đại diện cho một Google account trong danh sách.
///
/// Dùng dữ liệu động — KHÔNG hardcode.
class GoogleAccount {
  final String name;
  final String email;
  final String? avatarUrl;

  const GoogleAccount({
    required this.name,
    required this.email,
    this.avatarUrl,
  });
}

class GoogleAccountPickerScreen extends StatefulWidget {
  /// Danh sách Google accounts đã đăng nhập trước đó.
  ///
  /// Nếu empty, chỉ hiển thị nút "Add another account".
  final List<GoogleAccount> accounts;

  const GoogleAccountPickerScreen({
    super.key,
    this.accounts = const [],
  });

  @override
  State<GoogleAccountPickerScreen> createState() =>
      _GoogleAccountPickerScreenState();
}

class _GoogleAccountPickerScreenState extends State<GoogleAccountPickerScreen>
    with TickerProviderStateMixin {
  // Google auth service để gọi signInWithTokens
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  bool _isSigningIn = false;

  // ── Staggered fade-up animations (đồng bộ CSS) ─────────────────────────
  // CSS: fadeUp 0.4s ease-out, stagger-1: 0.1s, stagger-2: 0.2s, stagger-3: 0.3s
  late final AnimationController _animController;
  late final Animation<double> _fadeHeader;
  late final Animation<Offset> _slideHeader;
  late final Animation<double> _fadeList;
  late final Animation<Offset> _slideList;
  late final Animation<double> _fadeFooter;
  late final Animation<Offset> _slideFooter;

  // Design tokens (đồng bộ HTML Tailwind config)
  static const _background = Color(0xFFF8F9FF);       // background
  static const _onSurface = Color(0xFF0B1C30);         // on-surface
  static const _onSurfaceVariant = Color(0xFF5A4139);  // on-surface-variant
  static const _primary = Color(0xFFA83300);            // primary

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Header: fadeUp 0.4s, no delay
    _fadeHeader = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0, 0.57, curve: Curves.easeOut), // 0.4s/0.7s
      ),
    );
    _slideHeader = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0, 0.57, curve: Curves.easeOut),
    ));

    // List: fadeUp 0.4s, delay 0.1s → starts at 0.14 of 0.7
    _fadeList = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.14, 0.71, curve: Curves.easeOut),
      ),
    );
    _slideList = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.14, 0.71, curve: Curves.easeOut),
    ));

    // Footer: fadeUp 0.4s, delay 0.2s → starts at 0.28
    _fadeFooter = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.28, 0.86, curve: Curves.easeOut),
      ),
    );
    _slideFooter = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.28, 0.86, curve: Curves.easeOut),
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Handle account selection ────────────────────────────────────────────
  /// Khi user chọn account đã có → thực hiện Google Sign-In → gửi idToken lên BE.
  Future<void> _onAccountSelected(GoogleAccount account) async {
    if (_isSigningIn) return;
    setState(() => _isSigningIn = true);

    try {
      final tokens = await _googleAuthService.signInWithTokens();
      if (tokens == null || !mounted) {
        if (mounted) setState(() => _isSigningIn = false);
        return;
      }

      // Gửi cả idToken + accessToken lên BE, BE tự chọn phương thức verify
      final idToken = tokens.idToken ?? '';
      final accessToken = tokens.accessToken ?? '';

      if (idToken.isEmpty && accessToken.isEmpty) {
        if (mounted) {
          setState(() => _isSigningIn = false);
          _showError('Không thể lấy token từ Google. Vui lòng thử lại.');
        }
        return;
      }

      // Dispatch Google login event → AuthBloc handles the rest
      if (mounted) {
        context.read<AuthBloc>().add(
          GoogleLoginSubmitted(idToken: idToken, accessToken: accessToken),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSigningIn = false);
        final msg = e.toString().replaceAll('Exception: ', '');
        _showError(msg.isNotEmpty ? msg : 'Lỗi đăng nhập Google. Vui lòng thử lại.');
      }
    }
  }

  /// Khi user tap "Add another account" → mở Google Sign-In picker.
  Future<void> _onAddAnotherAccount() async {
    if (_isSigningIn) return;
    setState(() => _isSigningIn = true);

    try {
      // Disconnect trước để Google cho chọn account khác
      await _googleAuthService.signOut();

      final tokens = await _googleAuthService.signInWithTokens();
      if (tokens == null || !mounted) {
        if (mounted) setState(() => _isSigningIn = false);
        return;
      }

      // Gửi cả idToken + accessToken lên BE, BE tự chọn phương thức verify
      final idToken = tokens.idToken ?? '';
      final accessToken = tokens.accessToken ?? '';

      if (idToken.isEmpty && accessToken.isEmpty) {
        if (mounted) {
          setState(() => _isSigningIn = false);
          _showError('Không thể lấy token từ Google. Vui lòng thử lại.');
        }
        return;
      }

      if (mounted) {
        context.read<AuthBloc>().add(
          GoogleLoginSubmitted(idToken: idToken, accessToken: accessToken),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSigningIn = false);
        final msg = e.toString().replaceAll('Exception: ', '');
        _showError(msg.isNotEmpty ? msg : 'Lỗi đăng nhập Google. Vui lòng thử lại.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFBA1A1A), // error
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.go(AppRouter.examList);
          } else if (state is AuthFailure) {
            setState(() => _isSigningIn = false);
            _showError(state.errorMessage);
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // ── Top App Bar ─────────────────────────────────────────────
              _buildTopBar(),

              // ── Main Content ────────────────────────────────────────────
              Expanded(
                child: Padding(
                  // px-container-padding: 16px, py-lg: 24px, pb-xl: 32px
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  child: Column(
                    children: [
                      // ── Google Branding Header ──────────────────────────
                      FadeTransition(
                        opacity: _fadeHeader,
                        child: SlideTransition(
                          position: _slideHeader,
                          child: _buildGoogleHeader(),
                        ),
                      ),

                      const SizedBox(height: 32), // mb-xl: 32px

                      // ── Account List ────────────────────────────────────
                      Expanded(
                        child: FadeTransition(
                          opacity: _fadeList,
                          child: SlideTransition(
                            position: _slideList,
                            child: _buildAccountList(),
                          ),
                        ),
                      ),

                      // ── Footer ──────────────────────────────────────────
                      FadeTransition(
                        opacity: _fadeFooter,
                        child: SlideTransition(
                          position: _slideFooter,
                          child: const Padding(
                            padding: EdgeInsets.only(top: 32), // pt-xl: 32px
                            child: GoogleFooterWidget(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Widget Builders
  // ══════════════════════════════════════════════════════════════════════════

  /// Top App Bar — pixel-perfect từ HTML header.
  ///
  /// HTML:
  ///   <header class="flex justify-between items-center w-full px-16 py-16">
  ///     <button aria-label="Go back" class="w-[40px] h-[40px] ...">
  ///       arrow_back
  ///     </button>
  ///     <h1 class="font-title-lg text-title-lg text-on-surface">Sign in</h1>
  ///     <div class="w-[40px]"></div> <!-- Spacer -->
  ///   </header>
  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16, // px-container-padding
        vertical: 16,   // py-md
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Back button (left) ──────────────────────────────────────────
          Positioned(
            left: 0,
            child: GestureDetector(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRouter.login);
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: _onSurface,
                  size: 24,
                ),
              ),
            ),
          ),
          // ── Title (center) ─────────────────────────────────────────────
          // font-title-lg text-title-lg: 18px, 26px line, weight 600
          const Text(
            'Sign in',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _onSurface,
              height: 1.44, // 26/18
            ),
          ),
          // ── Spacer (right) — w-[40px] ──────────────────────────────────
          const Positioned(
            right: 0,
            child: SizedBox(width: 40),
          ),
        ],
      ),
    );
  }

  /// Google branding header — logo + title + subtitle.
  ///
  /// HTML:
  ///   <div class="flex flex-col items-center mb-xl">
  ///     <div class="w-16 h-16 mb-md"> Google Logo </div>
  ///     <h2 class="headline-md">Choose an account</h2>
  ///     <p class="body-md">to continue to <strong>FPT ExamHub</strong></p>
  ///   </div>
  Widget _buildGoogleHeader() {
    return Column(
      children: [
        // ── Google Logo (w-16 h-16 = 64px, mb-md: 16px) ─────────────────
        const GoogleLogoWidget(size: 64),
        const SizedBox(height: 16), // mb-md

        // ── "Choose an account" ──────────────────────────────────────────
        // headline-md: 24px, lineHeight 32px, letterSpacing -0.01em, weight 600
        const Text(
          'Choose an account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.24, // -0.01em
            color: _onSurface,
            height: 1.33, // 32/24
          ),
        ),

        const SizedBox(height: 8), // mb-xs

        // ── "to continue to FPT ExamHub" ─────────────────────────────────
        // body-md: 14px, lineHeight 20px, weight 400
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _onSurfaceVariant,
              height: 1.43, // 20/14
            ),
            children: [
              TextSpan(text: 'to continue to '),
              TextSpan(
                text: 'FPT ExamHub',
                style: TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Account list + "Add another account" button.
  Widget _buildAccountList() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ── Existing accounts ────────────────────────────────────────────
          // flex-col gap-xs: 8px
          ...widget.accounts.asMap().entries.map((entry) {
            final index = entry.key;
            final account = entry.value;

            // Alternate avatar colors for accounts without photo
            final avatarColors = [
              const Color(0xFFBBD3FD), // secondary-container
              const Color(0xFF447A9C), // tertiary-container
              const Color(0xFF485F84), // secondary
            ];

            return Padding(
              padding: EdgeInsets.only(bottom: index < widget.accounts.length - 1 ? 8 : 0),
              child: GoogleAccountTile(
                displayName: account.name,
                email: account.email,
                avatarUrl: account.avatarUrl,
                avatarBackgroundColor: avatarColors[index % avatarColors.length],
                onTap: _isSigningIn ? null : () => _onAccountSelected(account),
              ),
            );
          }),

          // ── "Add another account" button ────────────────────────────────
          // mt-sm: 12px
          Padding(
            padding: EdgeInsets.only(
              top: widget.accounts.isNotEmpty ? 12 : 0,
            ),
            child: _buildAddAccountButton(),
          ),
        ],
      ),
    );
  }

  /// "Add another account" button — đúng layout HTML.
  ///
  /// HTML:
  ///   <button class="account-item w-full flex items-center p-md ...">
  ///     <div class="w-10 h-10 rounded-full ... text-on-surface-variant">
  ///       person_add
  ///     </div>
  ///     <span class="font-title-lg text-body-lg font-semibold text-on-surface">
  ///       Add another account
  ///     </span>
  ///   </button>
  Widget _buildAddAccountButton() {
    return GestureDetector(
      onTap: _isSigningIn ? null : _onAddAnotherAccount,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16), // p-md
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF), // surface-container-lowest
          borderRadius: BorderRadius.circular(8), // rounded-lg
          border: Border.all(
            color: const Color(0xFFD3E4FE), // surface-variant
          ),
        ),
        child: Row(
          children: [
            // Icon circle (w-10 h-10, no bg, just icon)
            SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: _isSigningIn
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.person_add_outlined,
                        size: 24,
                        color: _onSurfaceVariant,
                      ),
              ),
            ),
            const SizedBox(width: 12), // mr-sm

            // Text
            const Expanded(
              child: Text(
                'Add another account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _onSurface,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
