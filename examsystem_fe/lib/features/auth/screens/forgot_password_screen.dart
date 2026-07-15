import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/forgot_password_bloc.dart';
import '../bloc/forgot_password_event.dart';
import '../bloc/forgot_password_state.dart';

// ════════════════════════════════════════════════════════════════════════════
// ForgotPasswordScreen — Màn hình quên mật khẩu.
//
// Chuyển đổi 100% từ thiết kế HTML trong FOGOTPASS.txt.
// Cho phép người dùng nhập email để nhận link đặt lại mật khẩu.
//
// Sử dụng BlocConsumer để quản lý trạng thái (đồng bộ với AuthBloc pattern).
// ════════════════════════════════════════════════════════════════════════════
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Gửi yêu cầu đặt lại mật khẩu qua BLoC
  void _submitForgotPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();

      context.read<ForgotPasswordBloc>().add(
            ForgotPasswordSubmitted(email: _emailController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
          listener: (context, state) {
            if (state is ForgotPasswordFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: Colors.red[700],
                  ),
                );
            }
          },
          builder: (context, state) {
            final isLoading = state is ForgotPasswordLoading;
            final successState = state is ForgotPasswordSuccess ? state : null;

            return Column(
              children: [
                // ── Header: Back Button ─────────────────────────────────
                _buildBackHeader(),

                // ── Main Content ────────────────────────────────────────
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ── Logo ──────────────────────────────────────
                            _buildLogo(),

                            const SizedBox(height: 24),

                            // ── Typography ────────────────────────────────
                            _buildTypography(),

                            const SizedBox(height: 32),

                            // ── Form Card ─────────────────────────────────
                            successState != null
                                ? _buildSuccessCard(successState)
                                : _buildFormCard(isLoading),

                            const SizedBox(height: 24),

                            // ── Footer: Back to Login ─────────────────────
                            _buildFooter(),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Header với nút quay lại
  Widget _buildBackHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 56,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF1D3557),
              ),
              tooltip: 'Go back',
            ),
          ),
        ),
      ),
    );
  }

  /// Logo tròn cam FPT
  Widget _buildLogo() {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF15A22),
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
    );
  }

  /// Tiêu đề và mô tả
  Widget _buildTypography() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Forgot Password ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D3557),
                letterSpacing: -0.5,
              ),
            ),
            Icon(
              Icons.lock_outline,
              color: Color(0xFFF15A22),
              size: 24,
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Enter your email address and we'll send you a link to reset your password.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }

  /// Card chứa form nhập email
  Widget _buildFormCard(bool isLoading) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Email Input Field ─────────────────────────────────
            _buildEmailField(isLoading),

            const SizedBox(height: 16),

            // ── Submit Button ─────────────────────────────────────
            _buildSubmitButton(isLoading),
          ],
        ),
      ),
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
            'Email Address',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1D3557),
              letterSpacing: 0.5,
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
            controller: _emailController,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submitForgotPassword(),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF0B1C30),
            ),
            decoration: const InputDecoration(
              hintText: 'student@fpt.edu.vn',
              hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
              prefixIcon: Icon(
                Icons.mail_outline,
                color: Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 15),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập email';
              }
              // Validate email format
              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  /// Nút gửi yêu cầu
  Widget _buildSubmitButton(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: isLoading ? null : _submitForgotPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF15A22),
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                const Color(0xFFF15A22).withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Send Reset Link',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.send, size: 20),
                  ],
                ),
        ),
      ),
    );
  }

  /// Card hiển thị khi email đã gửi thành công
  Widget _buildSuccessCard(ForgotPasswordSuccess state) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Icon thành công
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF34A853).withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: Color(0xFF34A853),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Check your email!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D3557),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ve sent a password reset link to\n${state.email}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // Nút gửi lại
          TextButton(
            onPressed: () {
              // Gửi lại yêu cầu qua BLoC
              context.read<ForgotPasswordBloc>().add(
                    ForgotPasswordSubmitted(email: state.email),
                  );
            },
            child: const Text(
              'Didn\'t receive the email? Try again',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFF15A22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Footer với link quay lại trang đăng nhập
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Remember your password? ',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        GestureDetector(
          onTap: () => context.pop(),
          child: Row(
            children: const [
              Text(
                'Back to Login',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF15A22),
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.arrow_forward,
                color: Color(0xFFF15A22),
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
