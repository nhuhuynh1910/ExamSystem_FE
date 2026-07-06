import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';
import '../models/register_request.dart';
import 'register_event.dart';
import 'register_state.dart';

// ════════════════════════════════════════════════════════════════════════════
// RegisterBloc — Quản lý logic đăng ký tài khoản.
//
// Luồng:
//   RegisterSubmitted → emit(RegisterLoading) → gọi API
//     ├── Thành công → emit(RegisterSuccess(message))
//     └── Thất bại  → emit(RegisterFailure(errorMessage))
// ════════════════════════════════════════════════════════════════════════════
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _authRepository;

  RegisterBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl(),
        super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  /// Xử lý sự kiện đăng ký.
  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(const RegisterLoading());

    try {
      final request = RegisterRequest(
        fullName: event.fullName.trim(),
        email:    event.email.trim().toLowerCase(),
        username: event.username.trim(),
        password: event.password,
        role:     event.role,
      );

      // POST /api/auth/register → trả về message string
      final message = await _authRepository.register(request);

      emit(RegisterSuccess(message));
    } catch (e) {
      final raw = e.toString().replaceAll('Exception: ', '');

      // Kiểm tra trường hợp đặc biệt: email đã đăng ký nhưng chưa verify
      // AuthRepositoryImpl mã hóa: 'EMAIL_NOT_VERIFIED:<message>'
      if (raw.startsWith('EMAIL_NOT_VERIFIED:')) {
        final msg = raw.replaceFirst('EMAIL_NOT_VERIFIED:', '');
        emit(RegisterFailure(
          msg.isNotEmpty ? msg : 'Email đã được đăng ký nhưng chưa xác nhận.',
          requiresEmailVerification: true,
        ));
      } else {
        emit(RegisterFailure(raw));
      }
    }
  }
}
