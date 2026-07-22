import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';
import '../models/forgot_password_request.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

// ════════════════════════════════════════════════════════════════════════════
// ForgotPasswordBloc — Quản lý logic quên mật khẩu.
//
// Luồng:
//   ForgotPasswordSubmitted → emit(ForgotPasswordLoading) → gọi API
//     ├── Thành công → emit(ForgotPasswordSuccess(message, email))
//     └── Thất bại  → emit(ForgotPasswordFailure(errorMessage))
// ════════════════════════════════════════════════════════════════════════════
class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final AuthRepository _authRepository;

  ForgotPasswordBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl(),
        super(const ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
  }

  /// Xử lý sự kiện gửi yêu cầu quên mật khẩu.
  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());

    try {
      final request = ForgotPasswordRequest(
        email: event.email.trim().toLowerCase(),
      );

      // POST /api/auth/forgot-password → trả về message string
      final message = await _authRepository.forgotPassword(request);

      emit(ForgotPasswordSuccess(message: message, email: event.email.trim()));
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(ForgotPasswordFailure(errorMessage));
    }
  }
}
