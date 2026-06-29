import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

// ════════════════════════════════════════════════════════════════════════════
// LoginScreen — Màn hình đăng nhập FPT ExamHub.
//
// Chuyển đổi 100% từ thiết kế HTML trong Login Screen.txt.
// Tích hợp BLoC để gọi API Backend và chuyển trang.
// ════════════════════════════════════════════════════════════════════════════
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Trạng thái hiện/ẩn mật khẩu
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Thực hiện gửi yêu cầu đăng nhập lên AuthBloc
  void _submitLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      // Ẩn bàn phím ảo
      FocusScope.of(context).unfocus();

      context.read<AuthBloc>().add(
            LoginSubmitted(
              emailOrUsername: _emailController.text,
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nền sáng nhạt (#f8f9ff) — đồng bộ background từ HTML.
      backgroundColor: const Color(0xFFF8F9FF),
      // Tắt resize khi bàn phím xuất hiện — tránh lỗi Flutter Web:
      // "_viewInsets.isNonNegative" assertion khi keyboard dismiss.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              // Đăng nhập thành công → Điều hướng sang trang Exams chủ
              context.go(AppRouter.examList);
            } else if (state is AuthFailure) {
              // Đăng nhập thất bại → Hiển thị lỗi từ Backend thông qua SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: const Color(0xFFBA1A1A), // màu error: #ba1a1a
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),

                      // ── Header: Logo & Title ───────────────────────────────
                      _buildHeader(),

                      const SizedBox(height: 32),

                      // ── Main Card Form ─────────────────────────────────────
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16), // rounded-card: 16px
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05), // shadow từ HTML
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ── Trường Email ──────────────────────────────
                              _buildEmailField(isLoading),

                              const SizedBox(height: 16),

                              // ── Trường Mật khẩu ───────────────────────────
                              _buildPasswordField(isLoading),

                              const SizedBox(height: 24),

                              // ── Nút Đăng nhập ─────────────────────────────
                              _buildSubmitButton(isLoading),

                              const SizedBox(height: 20),

                              // ── Đường gạch phân cách ──────────────────────
                              _buildDivider(),

                              const SizedBox(height: 20),

                              // ── Nút Đăng nhập qua Google ──────────────────
                              _buildGoogleButton(isLoading),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Footer: Link Đăng ký ───────────────────────────────
                      _buildFooter(),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Tiêu đề logo đầu màn hình
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo tròn cam FPT
        Container(
          width: 56, // w-[56px] trong HTML
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF15A22), // FPT Orange
                Color(0xFFD14307),
              ],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Welcome back 👋',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D3557), // brand-navy: #1D3557
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sign in to your FPT account',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280), // #6B7280 từ HTML
          ),
        ),
      ],
    );
  }

  /// Widget nhập email
  Widget _buildEmailField(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'Email address',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1D3557), // brand-navy
            ),
          ),
        ),
        Container(
          height: 52, // h-[52px] trong HTML
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9), // bg-[#F1F5F9]
            borderRadius: BorderRadius.circular(10), // rounded-input: 10px
          ),
          child: TextFormField(
            controller: _emailController,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF0B1C30), // on-surface
            ),
            decoration: const InputDecoration(
              hintText: 'Email address',
              hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
                color: Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 15),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập email hoặc tên đăng nhập';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  /// Widget nhập mật khẩu
  Widget _buildPasswordField(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'Password',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1D3557),
            ),
          ),
        ),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: _passwordController,
            enabled: !isLoading,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submitLogin(),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF0B1C30),
            ),
            decoration: InputDecoration(
              hintText: 'Password',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF9CA3AF),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF9CA3AF),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              if (value.length < 6) {
                return 'Mật khẩu phải từ 6 ký tự trở lên';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: isLoading
                ? null
                : () {
                    // TODO: Xử lý quên mật khẩu
                  },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFFF15A22), // brand-primary: #F15A22
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Nút Đăng nhập chính
  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      height: 52, // h-[52px]
      child: ElevatedButton(
        onPressed: isLoading ? null : _submitLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF15A22), // brand-primary: #F15A22
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFF15A22).withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // rounded-btn: 12px
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// Đường gạch kẻ phân cách
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ],
    );
  }

  /// Nút Google
  Widget _buildGoogleButton(bool isLoading) {
    return SizedBox(
      height: 48, // h-[48px]
      child: OutlinedButton(
        onPressed: isLoading
            ? null
            : () {
                // TODO: Đăng nhập bằng Google
              },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // rounded-input
          ),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1D3557), // brand-navy
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Vẽ logo Google bằng các Shapes để tránh cần nhúng file svg/png
            CustomPaint(
              size: const Size(20, 20),
              painter: _GoogleIconPainter(),
            ),
            const SizedBox(width: 12),
            const Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Phần text đăng ký tài khoản mới ở cuối
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF1D3557),
          ),
        ),
        GestureDetector(
          onTap: () {
            // Chuyển hướng sang màn hình đăng ký
            context.go(AppRouter.register);
          },
          child: const Text(
            'Register',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFF15A22), // brand-primary: #F15A22
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _GoogleIconPainter — Vẽ Icon Google bằng Vector để không cần file ảnh.
// ════════════════════════════════════════════════════════════════════════════
class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Phân chia màu sắc logo Google đúng chuẩn: đỏ, vàng, xanh lá, xanh dương
    final Paint bluePaint = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill;
    final Paint greenPaint = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.fill;
    final Paint yellowPaint = Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.fill;
    final Paint redPaint = Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.fill;

    // Vẽ phần xanh dương
    final Path bluePath = Path()
      ..moveTo(w * 0.94, h * 0.51)
      ..arcToPoint(Offset(w * 0.94, h * 0.41), radius: Radius.circular(w * 0.5), clockwise: false)
      ..lineTo(w * 0.5, h * 0.5)
      ..close();
    canvas.drawPath(bluePath, bluePaint);
    
    // Vẽ phần gạch ngang xanh dương của chữ G
    final Rect blueBar = Rect.fromLTRB(w * 0.5, h * 0.41, w * 0.95, h * 0.59);
    canvas.drawRect(blueBar, bluePaint);

    // Vẽ phần màu đỏ (phía trên chữ G)
    final Path redPath = Path()
      ..moveTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.18, h * 0.29)
      ..arcToPoint(Offset(w * 0.81, h * 0.22), radius: Radius.circular(w * 0.5))
      ..close();
    canvas.drawPath(redPath, redPaint);

    // Vẽ phần màu vàng (bên trái chữ G)
    final Path yellowPath = Path()
      ..moveTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.18, h * 0.71)
      ..arcToPoint(Offset(w * 0.18, h * 0.29), radius: Radius.circular(w * 0.5))
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Vẽ phần màu xanh lá (phía dưới chữ G)
    final Path greenPath = Path()
      ..moveTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.81, h * 0.78)
      ..arcToPoint(Offset(w * 0.18, h * 0.71), radius: Radius.circular(w * 0.5))
      ..close();
    canvas.drawPath(greenPath, greenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
