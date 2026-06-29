import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';

// ════════════════════════════════════════════════════════════════════════════
// RegisterScreen — Màn hình Đăng ký tài khoản FPT ExamHub.
//
// Chuyển đổi pixel-perfect từ dangkybangform.txt (HTML/Tailwind).
//
// Các trường form:
//   ✅ Full Name      → backend: fullName
//   ✅ Student ID     → backend: username
//   ✅ Email address  → backend: email
//   ✅ Password       → backend: password
//   ⛔ Confirm Pwd   → chỉ validate tại Flutter, KHÔNG gửi BE
//   ⛔ Role chip      → chỉ visual, BE hardcode RoleId=3(Student)
//   ⛔ Terms checkbox → chỉ validate tại Flutter, KHÔNG gửi BE
// ════════════════════════════════════════════════════════════════════════════
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController    = TextEditingController();
  final _usernameController    = TextEditingController();
  final _emailController       = TextEditingController();
  final _passwordController    = TextEditingController();
  final _confirmPwdController  = TextEditingController();

  bool _obscurePassword    = true;
  bool _obscureConfirmPwd  = true;
  bool _acceptedTerms      = true;

  // Role UI state — purely visual (BE does not receive this)
  // 'Student' | 'Teacher'  (hardcoded as Student in backend)
  String _selectedRole = 'Student';

  // Design tokens (đồng bộ với HTML)
  static const _orange   = Color(0xFFF15A22);
  static const _navy     = Color(0xFF1D3557);
  static const _grey     = Color(0xFF6B7280);
  static const _bgColor  = Color(0xFFFAFAFA);
  static const _white    = Colors.white;
  static const _slate    = Color(0xFFE2E8F0);
  static const _inputBg  = Color(0xFFF1F5F9);

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPwdController.dispose();
    super.dispose();
  }

  // ── Submit ──────────────────────────────────────────────────────────────
  void _submit() {
    // Kiểm tra checkbox terms trước
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar('Vui lòng đồng ý với Điều khoản & Chính sách Bảo mật.'),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();

      context.read<RegisterBloc>().add(
            RegisterSubmitted(
              fullName: _fullNameController.text,
              email:    _emailController.text,
              username: _usernameController.text,
              password: _passwordController.text,
              // confirmPassword và role KHÔNG gửi lên BE
            ),
          );
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  SnackBar _buildSnackBar(String message, {bool isSuccess = false}) {
    return SnackBar(
      content: Text(message),
      backgroundColor:
          isSuccess ? const Color(0xFF2E7D32) : const Color(0xFFBA1A1A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            // Thành công → show dialog xác nhận email rồi về Login
            _showSuccessDialog(state.message);
          } else if (state is RegisterFailure) {
            if (state.requiresEmailVerification) {
              // Email đã đăng ký nhưng chưa verify
              _showEmailVerificationDialog(state.errorMessage);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                _buildSnackBar(state.errorMessage),
              );
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is RegisterLoading;

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header / Back button (h-14 trong HTML) ─────────────
                    _buildHeader(),

                    const SizedBox(height: 8),

                    // ── Title section ───────────────────────────────────────
                    _buildTitleSection(),

                    const SizedBox(height: 24),

                    // ── Role selector chips ─────────────────────────────────
                    _buildRoleSelector(isLoading),

                    const SizedBox(height: 24),

                    // ── Form ────────────────────────────────────────────────
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _fullNameController,
                            hint: 'Full Name',
                            icon: Icons.person_outline_rounded,
                            enabled: !isLoading,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Vui lòng nhập họ tên đầy đủ';
                              }
                              if (v.trim().length > 100) {
                                return 'Họ tên tối đa 100 ký tự';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          _buildTextField(
                            controller: _usernameController,
                            hint: 'Username',
                            icon: Icons.badge_outlined,
                            enabled: !isLoading,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Vui lòng nhập Username';
                              }
                              if (v.trim().length > 100) {
                                return 'Username tối đa 100 ký tự';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          _buildTextField(
                            controller: _emailController,
                            hint: 'Email address',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !isLoading,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Vui lòng nhập email';
                              }
                              final emailRegex = RegExp(
                                r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
                              );
                              if (!emailRegex.hasMatch(v.trim())) {
                                return 'Email không hợp lệ';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          _buildPasswordField(
                            controller: _passwordController,
                            hint: 'Password',
                            obscure: _obscurePassword,
                            enabled: !isLoading,
                            textInputAction: TextInputAction.next,
                            onToggle: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              // Regex đồng bộ với BE: chữ + số + ký tự đặc biệt, ≥6 ký tự
                              final regex = RegExp(
                                r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z\d]).{6,}$',
                              );
                              if (!regex.hasMatch(v)) {
                                return 'Mật khẩu phải có ít nhất 6 ký tự,\nbao gồm chữ, số và ký tự đặc biệt';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          _buildPasswordField(
                            controller: _confirmPwdController,
                            hint: 'Confirm Password',
                            obscure: _obscureConfirmPwd,
                            enabled: !isLoading,
                            textInputAction: TextInputAction.done,
                            onToggle: () => setState(
                                () => _obscureConfirmPwd = !_obscureConfirmPwd),
                            onFieldSubmitted: (_) => _submit(),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Vui lòng xác nhận mật khẩu';
                              }
                              if (v != _passwordController.text) {
                                return 'Mật khẩu xác nhận không khớp';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // ── Terms checkbox ────────────────────────────────
                          _buildTermsCheckbox(isLoading),

                          const SizedBox(height: 16),

                          // ── Submit button ─────────────────────────────────
                          _buildSubmitButton(isLoading),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Footer: Sign In link ────────────────────────────────
                    _buildFooter(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Widget Builders ──────────────────────────────────────────────────────

  /// Header với nút back — h-14 trong HTML.
  Widget _buildHeader() {
    return SizedBox(
      height: 56,
      child: Align(
        alignment: Alignment.centerLeft,
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
            color: Colors.transparent,
            child: const Icon(
              Icons.arrow_back_rounded,
              color: _navy,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  /// Title "Create Account" và subtitle.
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _navy,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Join FPT ExamHub today',
          style: const TextStyle(
            fontSize: 14,
            color: _grey,
          ),
        ),
      ],
    );
  }

  /// Role selector chips — Student / Teacher.
  /// Purely visual: chỉ thay đổi placeholder của username field.
  Widget _buildRoleSelector(bool isLoading) {
    return Row(
      children: [
        Expanded(child: _buildRoleChip('Student', '🎓', isLoading)),
        const SizedBox(width: 12),
        Expanded(child: _buildRoleChip('Teacher', '👨‍🏫', isLoading)),
      ],
    );
  }

  Widget _buildRoleChip(String role, String emoji, bool isLoading) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: isLoading
          ? null
          : () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? _orange : _white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: _orange,
            width: isSelected ? 0 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              role,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.05,
                color: isSelected ? _white : _orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Text field chung (không có password toggle).
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: const TextStyle(
        fontSize: 14,
        color: _navy,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: _grey.withValues(alpha: 0.6),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Icon(icon, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 20,
        ),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return _orange;
          }
          return _grey;
        }),
        filled: true,
        fillColor: enabled ? _white : _inputBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _slate),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _slate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _orange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _slate.withValues(alpha: 0.5)),
        ),
      ),
      validator: validator,
    );
  }

  /// Password field với toggle show/hide.
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    bool enabled = true,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(
        fontSize: 14,
        color: _navy,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: _grey.withValues(alpha: 0.6),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 16, right: 12),
          child: Icon(Icons.lock_outline_rounded, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 20,
        ),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return _orange;
          }
          return _grey;
        }),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 20,
            ),
            color: _grey,
            onPressed: enabled ? onToggle : null,
          ),
        ),
        filled: true,
        fillColor: enabled ? _white : _inputBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _slate),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _slate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _orange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _slate.withValues(alpha: 0.5)),
        ),
      ),
      validator: validator,
    );
  }

  /// Checkbox đồng ý điều khoản.
  Widget _buildTermsCheckbox(bool isLoading) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: _acceptedTerms,
            onChanged: isLoading
                ? null
                : (v) => setState(() => _acceptedTerms = v ?? false),
            activeColor: _orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(color: _slate, width: 1.5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: isLoading
                ? null
                : () => setState(() => _acceptedTerms = !_acceptedTerms),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: _grey,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'I agree to '),
                  TextSpan(
                    text: 'Terms & Privacy Policy',
                    style: const TextStyle(
                      color: _orange,
                      decoration: TextDecoration.underline,
                      decorationColor: _orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Nút Submit "Create Account".
  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _orange,
          foregroundColor: _white,
          disabledBackgroundColor: _orange.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(_white),
                ),
              )
            : const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// Footer "Already have an account? Sign In"
  Widget _buildFooter() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: _grey),
          children: [
            const TextSpan(text: 'Already have an account? '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: () => context.go(AppRouter.login),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _orange,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────

  /// Dialog thành công → thông báo kiểm tra email → về Login.
  void _showSuccessDialog(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                color: Color(0xFF2E7D32),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Đăng ký thành công!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                // Thành công → về màn hình Login
                context.go(AppRouter.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: _white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Về trang Đăng nhập'),
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog khi email đã đăng ký nhưng chưa xác nhận.
  void _showEmailVerificationDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.email_outlined,
                color: Colors.amber.shade700,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Email chưa xác nhận',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng', style: TextStyle(color: _grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(AppRouter.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange,
              foregroundColor: _white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Đến Đăng nhập'),
          ),
        ],
      ),
    );
  }
}
