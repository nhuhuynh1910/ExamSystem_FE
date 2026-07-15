import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';
import '../models/reset_password_request.dart';
import 'reset_password_event.dart';
import 'reset_password_state.dart';

// ════════════════════════════════════════════════════════════════════════════
// ResetPasswordBloc — Quản lý logic đặt lại mật khẩu.
//
// Luồng:
//   ResetPasswordSubmitted → emit(ResetPasswordLoading) → gọi API
//     ├── Thành công → emit(ResetPasswordSuccess(message))
//     └── Thất bại  → emit(ResetPasswordFailure(errorMessage))
// ════════════════════════════════════════════════════════════════════════════
class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final AuthRepository _authRepository;

  ResetPasswordBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl(),
        super(const ResetPasswordInitial()) {
    on<ResetPasswordSubmitted>(_onResetPasswordSubmitted);
  }

  /// Xử lý sự kiện đặt lại mật khẩu.
  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmitted event,
    Emitter<ResetPasswordState> emit,
  ) async {
    emit(const ResetPasswordLoading());

    try {
      final request = ResetPasswordRequest(
        token: event.token,
        newPassword: event.newPassword,
      );

      // POST /api/auth/reset-password → trả về message string
      final message = await _authRepository.resetPassword(request);

      emit(ResetPasswordSuccess(message));
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(ResetPasswordFailure(errorMessage));
    }
  }
}
