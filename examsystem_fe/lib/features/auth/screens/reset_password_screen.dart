import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../bloc/reset_password_bloc.dart';
import '../bloc/reset_password_event.dart';
import '../bloc/reset_password_state.dart';

// ════════════════════════════════════════════════════════════════════════════
// ResetPasswordScreen — Màn hình đặt lại mật khẩu mới.
//
// Chuyển đổi 100% từ thiết kế HTML trong RESETPASS.txt.
// Người dùng nhập mật khẩu mới và xác nhận lại sau khi click link email.
//
// Sử dụng BlocConsumer để quản lý trạng thái (đồng bộ với AuthBloc pattern).
// ════════════════════════════════════════════════════════════════════════════
class ResetPasswordScreen extends StatefulWidget {
  /// Token xác thực từ link email (query param hoặc path param).
  final String token;

  const ResetPasswordScreen({
    super.key,
    required this.token,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Gửi yêu cầu đặt lại mật khẩu qua BLoC
  void _submitResetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();

      context.read<ResetPasswordBloc>().add(
            ResetPasswordSubmitted(
              token: widget.token,
              newPassword: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: BlocConsumer<ResetPasswordBloc, ResetPasswordState>(
          listener: (context, state) {
            if (state is ResetPasswordFailure) {
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
            final isLoading = state is ResetPasswordLoading;
            final isSuccess = state is ResetPasswordSuccess;

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
                            isSuccess
                                ? _buildSuccessCard()
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
      children: const [
        Text(
          'Set New Password 🔑',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D3557),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Your new password must be different to previously used passwords.',
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

  /// Card chứa form đặt lại mật khẩu
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
            // ── New Password Field ────────────────────────────────
            _buildPasswordField(
              label: 'New Password',
              controller: _passwordController,
              hintText: 'Enter new password',
              obscureText: _obscurePassword,
              isLoading: isLoading,
              onToggleVisibility: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your new password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                // Validate: must contain letters, numbers, and special chars
                final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
                final hasDigit = RegExp(r'\d').hasMatch(value);
                final hasSpecial = RegExp(r'[^A-Za-z\d]').hasMatch(value);
                if (!hasLetter || !hasDigit || !hasSpecial) {
                  return 'Password must contain letters, numbers, and special characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // ── Confirm Password Field ────────────────────────────
            _buildPasswordField(
              label: 'Confirm Password',
              controller: _confirmPasswordController,
              hintText: 'Confirm new password',
              obscureText: _obscureConfirmPassword,
              isLoading: isLoading,
              onToggleVisibility: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // ── Submit Button ─────────────────────────────────────
            _buildSubmitButton(isLoading),
          ],
        ),
      ),
    );
  }

  /// Widget nhập mật khẩu (tái sử dụng cho cả 2 field)
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required bool isLoading,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
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
            controller: controller,
            enabled: !isLoading,
            obscureText: obscureText,
            textInputAction: TextInputAction.done,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF0B1C30),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Color(0xFF9CA3AF),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF9CA3AF),
                ),
                onPressed: onToggleVisibility,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  /// Nút cập nhật mật khẩu
  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submitResetPassword,
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
            : const Text(
                'Update Password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// Card hiển thị khi đặt lại mật khẩu thành công
  Widget _buildSuccessCard() {
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
              Icons.check_circle_outline,
              color: Color(0xFF34A853),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Password Updated!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D3557),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your password has been changed successfully.\nYou can now sign in with your new password.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // Nút quay về Login
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.go(AppRouter.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF15A22),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Back to Sign In',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Footer với link quay lại trang đăng nhập
  Widget _buildFooter() {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.arrow_back,
            color: Color(0xFFF15A22),
            size: 14,
          ),
          SizedBox(width: 4),
          Text(
            'Back to Login',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFFF15A22),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
