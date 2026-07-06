import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../bloc/google_register_bloc.dart';
import '../bloc/google_register_event.dart';
import '../bloc/google_register_state.dart';
import '../data/google_auth_service.dart';

// ════════════════════════════════════════════════════════════════════════════
// GoogleCompleteRegistrationScreen — Hoàn tất đăng ký sau khi Google Sign-In.
//
// Chuyển đổi pixel-perfect từ dangkybanggoogle.txt (HTML/Tailwind).
//
// Hiển thị:
//   ✅ Google Profile Card (name, email, avatar — read-only)
//   ✅ Username field — user tự nhập (BE yêu cầu unique)
//   ✅ Role selection — Student / Teacher (visual only)
//   ✅ Campus dropdown (optional, visual only)
//   ✅ Terms checkbox
//   ✅ Complete Registration button
//
// Không gửi lên BE: role, campus, photoUrl — chỉ gửi fullName, email, username, password.
// ════════════════════════════════════════════════════════════════════════════
class GoogleCompleteRegistrationScreen extends StatefulWidget {
  /// Profile Google đã lấy từ bước Sign-In.
  final GoogleUserProfile googleProfile;

  const GoogleCompleteRegistrationScreen({
    super.key,
    required this.googleProfile,
  });

  @override
  State<GoogleCompleteRegistrationScreen> createState() =>
      _GoogleCompleteRegistrationScreenState();
}

class _GoogleCompleteRegistrationScreenState
    extends State<GoogleCompleteRegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  bool _acceptedTerms = false;
  String _selectedRole = 'Student';
  String? _selectedCampus;

  // Design tokens — đồng bộ với RegisterScreen hiện tại
  static const _orange = Color(0xFFF15A22);
  static const _navy = Color(0xFF1D3557);
  static const _grey = Color(0xFF6B7280);
  static const _bgColor = Color(0xFFFAFAFA);
  static const _white = Colors.white;
  static const _slate = Color(0xFFE2E8F0);
  static const _surfaceLight = Color(0xFFF8F9FF);

  // Animation
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ── Submit ──────────────────────────────────────────────────────────────
  void _submit() {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar('Vui lòng đồng ý với Điều khoản & Chính sách Bảo mật.'),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();

      context.read<GoogleRegisterBloc>().add(
            GoogleRegisterSubmitted(
              fullName: widget.googleProfile.fullName,
              email: widget.googleProfile.email,
              username: _usernameController.text,
              role: _selectedRole,
              photoUrl: widget.googleProfile.photoUrl,
            ),
          );
    }
  }

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
      body: BlocConsumer<GoogleRegisterBloc, GoogleRegisterState>(
        listener: (context, state) {
          if (state is GoogleRegisterSuccess) {
            _showSuccessDialog(state.message);
          } else if (state is GoogleRegisterFailure) {
            if (state.requiresEmailVerification) {
              _showEmailVerificationDialog(state.errorMessage);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                _buildSnackBar(state.errorMessage),
              );
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is GoogleRegisterLoading;

          return SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header ─────────────────────────────────────────
                        _buildHeader(),

                        const SizedBox(height: 8),

                        // ── Title ──────────────────────────────────────────
                        _buildTitleSection(),

                        const SizedBox(height: 20),

                        // ── Google Profile Card ────────────────────────────
                        _buildGoogleProfileCard(),

                        const SizedBox(height: 24),

                        // ── Username Field ─────────────────────────────────
                        Form(
                          key: _formKey,
                          child: _buildUsernameField(isLoading),
                        ),

                        const SizedBox(height: 24),

                        // ── Role Selection ─────────────────────────────────
                        _buildRoleSection(isLoading),

                        const SizedBox(height: 16),

                        // ── Campus Dropdown ────────────────────────────────
                        _buildCampusDropdown(isLoading),

                        const SizedBox(height: 16),

                        // ── Terms checkbox ─────────────────────────────────
                        _buildTermsCheckbox(isLoading),

                        const SizedBox(height: 24),

                        // ── Submit button ──────────────────────────────────
                        _buildSubmitButton(isLoading),

                        const SizedBox(height: 32),

                        // ── Footer ─────────────────────────────────────────
                        _buildFooter(),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Widget Builders
  // ══════════════════════════════════════════════════════════════════════════

  /// Header với logo FPT ExamHub + nút back.
  Widget _buildHeader() {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back button
          Positioned(
            left: 0,
            child: GestureDetector(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRouter.register);
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _surfaceLight.withValues(alpha: 0.8),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: _navy,
                  size: 24,
                ),
              ),
            ),
          ),
          // Logo + Title
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school_rounded, color: _orange, size: 22),
              const SizedBox(width: 8),
              const Text(
                'FPT ExamHub',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Title section.
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Center(
          child: Text(
            'Complete Registration',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: _navy,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Please confirm your details to set up\nyour FPT ExamHub account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _grey.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// Google profile card — avatar, tên, email (read-only).
  Widget _buildGoogleProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _slate.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Google Badge ──────────────────────────────────────────────
          Transform.translate(
            offset: const Offset(0, -32),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _slate.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Google logo mini
                  CustomPaint(
                    size: const Size(16, 16),
                    painter: _GoogleIconPainter(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'GOOGLE ACCOUNT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: _grey.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Adjust spacing after badge offset
          const SizedBox(height: 0),

          // ── Avatar ─────────────────────────────────────────────────────
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _slate.withValues(alpha: 0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: _orange.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: widget.googleProfile.photoUrl != null
                  ? Image.network(
                      widget.googleProfile.photoUrl!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, e, s) => _buildAvatarFallback(),
                    )
                  : _buildAvatarFallback(),
            ),
          ),

          const SizedBox(height: 12),

          // ── Name + Email ───────────────────────────────────────────────
          Text(
            widget.googleProfile.fullName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _navy,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            widget.googleProfile.email,
            style: TextStyle(
              fontSize: 14,
              color: _grey.withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),

          // ── Divider ────────────────────────────────────────────────────
          Container(
            height: 1,
            color: _slate.withValues(alpha: 0.3),
          ),

          const SizedBox(height: 16),

          // ── Read-only Fields ───────────────────────────────────────────
          _buildReadOnlyField('Full Name', widget.googleProfile.fullName),
          const SizedBox(height: 10),
          _buildReadOnlyField('Email Address', widget.googleProfile.email),
        ],
      ),
    );
  }

  /// Read-only field (locked).
  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: _navy,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _surfaceLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _slate.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _navy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: _grey.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Username text field.
  Widget _buildUsernameField(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose a Username',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _navy,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'This will be your unique identifier on FPT ExamHub.',
          style: TextStyle(
            fontSize: 13,
            color: _grey.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _usernameController,
          enabled: !isLoading,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          style: const TextStyle(
            fontSize: 14,
            color: _navy,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your username',
            hintStyle: TextStyle(
              color: _grey.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 16, right: 12),
              child: Icon(Icons.badge_outlined, size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 20,
            ),
            prefixIconColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.focused)) return _orange;
              return _grey;
            }),
            filled: true,
            fillColor: isLoading ? _surfaceLight : _white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
              borderSide:
                  const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
            ),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Vui lòng nhập username';
            }
            if (v.trim().length > 100) {
              return 'Username tối đa 100 ký tự';
            }
            if (v.trim().length < 3) {
              return 'Username phải có ít nhất 3 ký tự';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Role selection section — Student / Teacher.
  Widget _buildRoleSection(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Your Role',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _navy,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose how you will use FPT ExamHub.',
          style: TextStyle(
            fontSize: 13,
            color: _grey.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildRoleCard(
                role: 'Student',
                icon: Icons.backpack_outlined,
                isSelected: _selectedRole == 'Student',
                isLoading: isLoading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoleCard(
                role: 'Teacher',
                icon: Icons.co_present_outlined,
                isSelected: _selectedRole == 'Teacher',
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Individual role card.
  Widget _buildRoleCard({
    required String role,
    required IconData icon,
    required bool isSelected,
    required bool isLoading,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: 110,
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _orange : _slate.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _orange.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            // Background tint
            if (isSelected)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: _orange.withValues(alpha: 0.03),
                ),
              ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: isSelected ? _orange : _grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? _orange : _navy,
                    ),
                  ),
                ],
              ),
            ),
            // Check icon
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedScale(
                  scale: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: _orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: _white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Campus dropdown.
  Widget _buildCampusDropdown(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Campus',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: _navy,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _slate),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedCampus,
            isExpanded: true,
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
              hintText: 'Select your campus',
              hintStyle: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
            ),
            icon: Icon(
              Icons.expand_more_rounded,
              color: _grey.withValues(alpha: 0.6),
            ),
            dropdownColor: _white,
            borderRadius: BorderRadius.circular(12),
            items: const [
              DropdownMenuItem(
                value: 'hanoi',
                child: Text('FPT University Ha Noi'),
              ),
              DropdownMenuItem(
                value: 'hcmc',
                child: Text('FPT University Ho Chi Minh'),
              ),
              DropdownMenuItem(
                value: 'danang',
                child: Text('FPT University Da Nang'),
              ),
              DropdownMenuItem(
                value: 'cantho',
                child: Text('FPT University Can Tho'),
              ),
              DropdownMenuItem(
                value: 'quynhon',
                child: Text('FPT University Quy Nhon'),
              ),
            ],
            onChanged: isLoading
                ? null
                : (v) => setState(() => _selectedCampus = v),
          ),
        ),
      ],
    );
  }

  /// Terms checkbox.
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
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: const TextStyle(
                      color: _orange,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: _orange,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      color: _orange,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: _orange,
                    ),
                  ),
                  const TextSpan(text: ' of FPT ExamHub.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Submit button.
  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _orange,
          foregroundColor: _white,
          disabledBackgroundColor: _orange.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: _orange.withValues(alpha: 0.3),
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Complete Registration',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }

  /// Footer link.
  Widget _buildFooter() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: _grey),
          children: [
            const TextSpan(text: 'Want to register with email? '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: () => context.go(AppRouter.register),
                child: const Text(
                  'Use Form',
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

  /// Avatar fallback when Google photo is unavailable.
  Widget _buildAvatarFallback() {
    final initials = widget.googleProfile.fullName.isNotEmpty
        ? widget.googleProfile.fullName
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
            .join()
        : '?';

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _orange.withValues(alpha: 0.8),
            _orange,
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _white,
          ),
        ),
      ),
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────

  /// Dialog thành công.
  void _showSuccessDialog(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                color: Color(0xFF2E7D32),
                size: 22,
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.email_outlined,
                color: Colors.amber.shade700,
                size: 22,
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

// ════════════════════════════════════════════════════════════════════════════
// _GoogleIconPainter — Vẽ Icon Google bằng Vector.
//
// Reuse từ login_screen.dart (cùng logic).
// ════════════════════════════════════════════════════════════════════════════
class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final Paint greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;
    final Paint yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;
    final Paint redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;

    final Path bluePath = Path()
      ..moveTo(w * 0.94, h * 0.51)
      ..arcToPoint(Offset(w * 0.94, h * 0.41),
          radius: Radius.circular(w * 0.5), clockwise: false)
      ..lineTo(w * 0.5, h * 0.5)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    final Rect blueBar = Rect.fromLTRB(w * 0.5, h * 0.41, w * 0.95, h * 0.59);
    canvas.drawRect(blueBar, bluePaint);

    final Path redPath = Path()
      ..moveTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.18, h * 0.29)
      ..arcToPoint(Offset(w * 0.81, h * 0.22),
          radius: Radius.circular(w * 0.5))
      ..close();
    canvas.drawPath(redPath, redPaint);

    final Path yellowPath = Path()
      ..moveTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.18, h * 0.71)
      ..arcToPoint(Offset(w * 0.18, h * 0.29),
          radius: Radius.circular(w * 0.5))
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    final Path greenPath = Path()
      ..moveTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.81, h * 0.78)
      ..arcToPoint(Offset(w * 0.18, h * 0.71),
          radius: Radius.circular(w * 0.5))
      ..close();
    canvas.drawPath(greenPath, greenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
