import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository_impl.dart';
import '../data/google_auth_service.dart';
import '../domain/auth_repository.dart';
import '../models/register_request.dart';
import 'google_register_event.dart';
import 'google_register_state.dart';

// ════════════════════════════════════════════════════════════════════════════
// GoogleRegisterBloc — Quản lý logic đăng ký tài khoản qua Google.
//
// Luồng 2 bước:
//   1. GoogleSignInRequested → mở popup Google → emit GoogleSignInSuccess
//   2. GoogleRegisterSubmitted → auto-gen password → gọi API register
//
// Tách riêng khỏi RegisterBloc vì:
//   - Luồng Google có 2 bước (sign-in + submit), RegisterBloc chỉ có 1 bước.
//   - State khác nhau (thêm GoogleSignInLoading/Success).
//   - Dependency khác nhau (cần GoogleAuthService).
// ════════════════════════════════════════════════════════════════════════════
class GoogleRegisterBloc
    extends Bloc<GoogleRegisterEvent, GoogleRegisterState> {
  final GoogleAuthService _googleAuthService;
  final AuthRepository _authRepository;

  GoogleRegisterBloc({
    GoogleAuthService? googleAuthService,
    AuthRepository? authRepository,
  })  : _googleAuthService = googleAuthService ?? GoogleAuthService(),
        _authRepository = authRepository ?? AuthRepositoryImpl(),
        super(const GoogleRegisterInitial()) {
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<GoogleRegisterSubmitted>(_onGoogleRegisterSubmitted);
  }

  // ── Bước 1: Google Sign-In ──────────────────────────────────────────────
  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<GoogleRegisterState> emit,
  ) async {
    emit(const GoogleSignInLoading());

    try {
      final profile = await _googleAuthService.signIn();

      if (profile == null) {
        // User hủy popup Google → quay về trạng thái ban đầu
        emit(const GoogleRegisterInitial());
        return;
      }

      emit(GoogleSignInSuccess(profile));
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(GoogleSignInFailure(
        errorMessage.isNotEmpty
            ? errorMessage
            : 'Không thể đăng nhập bằng Google. Vui lòng thử lại.',
      ));
    }
  }

  // ── Bước 2: Gọi API Register ───────────────────────────────────────────
  Future<void> _onGoogleRegisterSubmitted(
    GoogleRegisterSubmitted event,
    Emitter<GoogleRegisterState> emit,
  ) async {
    emit(const GoogleRegisterLoading());

    try {
      // Auto-generate password an toàn cho Google user.
      // BE yêu cầu: ≥6 ký tự, có chữ + số + ký tự đặc biệt.
      final password = _generateSecurePassword();

      final request = RegisterRequest(
        fullName: event.fullName.trim(),
        email: event.email.trim().toLowerCase(),
        username: event.username.trim(),
        password: password,
        role: event.role,
        avatarUrl: event.photoUrl,
      );

      // Dùng cùng API register như đăng ký bằng form
      final message = await _authRepository.register(request);

      // Disconnect Google sau khi register thành công
      await _googleAuthService.signOut();

      emit(GoogleRegisterSuccess(message));
    } catch (e) {
      final raw = e.toString().replaceAll('Exception: ', '');

      // Trường hợp đặc biệt: email đã đăng ký nhưng chưa verify
      if (raw.startsWith('EMAIL_NOT_VERIFIED:')) {
        final msg = raw.replaceFirst('EMAIL_NOT_VERIFIED:', '');
        emit(GoogleRegisterFailure(
          msg.isNotEmpty
              ? msg
              : 'Email đã được đăng ký nhưng chưa xác nhận.',
          requiresEmailVerification: true,
        ));
      } else {
        emit(GoogleRegisterFailure(raw));
      }
    }
  }

  // ── Helper: Sinh mật khẩu an toàn ──────────────────────────────────────
  /// Sinh mật khẩu ngẫu nhiên thỏa mãn regex của BE:
  ///   ^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z\d]).{6,}$
  ///
  /// Format: 4 ký tự chữ + 4 số + 2 ký tự đặc biệt + 6 ký tự random
  /// Tổng cộng 16 ký tự, đảm bảo luôn hợp lệ.
  String _generateSecurePassword() {
    final random = Random.secure();

    const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const digits = '0123456789';
    const specials = '!@#\$%^&*_+-=';
    const all = '$letters$digits$specials';

    // Đảm bảo ít nhất 1 chữ, 1 số, 1 ký tự đặc biệt
    final buffer = <String>[
      letters[random.nextInt(letters.length)],
      letters[random.nextInt(letters.length)],
      digits[random.nextInt(digits.length)],
      digits[random.nextInt(digits.length)],
      specials[random.nextInt(specials.length)],
      specials[random.nextInt(specials.length)],
    ];

    // Thêm 10 ký tự random nữa (tổng 16 ký tự)
    for (var i = 0; i < 10; i++) {
      buffer.add(all[random.nextInt(all.length)]);
    }

    // Shuffle để không có pattern cố định
    buffer.shuffle(random);
    return buffer.join();
  }
}
