import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/utils/storage_manager.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';
import '../models/google_login_request.dart';
import '../models/login_request.dart';
import 'auth_event.dart';
import 'auth_state.dart';

// ════════════════════════════════════════════════════════════════════════════
// AuthBloc — Quản lý logic nghiệp vụ và luồng trạng thái cho tính năng xác thực.
// ════════════════════════════════════════════════════════════════════════════
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl(),
        super(const AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<GoogleLoginSubmitted>(_onGoogleLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  /// Xử lý sự kiện đăng nhập.
  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final request = LoginRequest(
        emailOrUsername: event.emailOrUsername.trim(),
        password: event.password,
      );

      // Gọi API đăng nhập ở máy chủ
      final response = await _authRepository.login(request);

      // Lưu trữ phiên đăng nhập vào SharedPreferences cục bộ
      await StorageManager.saveAuthData(
        userId: response.userId,
        fullName: response.fullName,
        email: response.email,
        username: response.username,
        role: response.role,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      // Reset DioClient instance để các request tiếp theo được gắn Access Token mới
      DioClient.resetInstance();

      emit(AuthSuccess(response));
    } catch (e) {
      // Trích xuất message lỗi từ Exception
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(AuthFailure(errorMessage));
    }
  }

  /// Xử lý sự kiện đăng nhập bằng Google.
  ///
  /// Tương tự [_onLoginSubmitted] nhưng:
  ///   - Nhận idToken thay vì email/password.
  ///   - Gọi `googleLogin()` thay vì `login()`.
  ///   - Cùng output: lưu AuthResponse vào StorageManager → navigate Home.
  Future<void> _onGoogleLoginSubmitted(
    GoogleLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final request = GoogleLoginRequest(
        idToken: event.idToken,
        accessToken: event.accessToken,
      );

      // Gọi API google-login trên BE
      final response = await _authRepository.googleLogin(request);

      // Lưu trữ phiên đăng nhập vào SharedPreferences
      await StorageManager.saveAuthData(
        userId: response.userId,
        fullName: response.fullName,
        email: response.email,
        username: response.username,
        role: response.role,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      // Reset DioClient để gắn Access Token mới
      DioClient.resetInstance();

      emit(AuthSuccess(response));
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(AuthFailure(errorMessage));
    }
  }

  /// Xử lý sự kiện đăng xuất.
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final refreshToken = await StorageManager.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        // Hủy phiên token trên Backend
        await _authRepository.logout(refreshToken);
      }
    } catch (_) {
      // Bỏ qua lỗi gọi API logout, vẫn tiến hành xóa local storage để bảo đảm UX
    } finally {
      // Xóa sạch thông tin lưu trữ cục bộ
      await StorageManager.clearAll();

      // Reset DioClient để xóa token cũ trong Headers
      DioClient.resetInstance();

      emit(const AuthInitial());
    }
  }
}

// ── Định nghĩa tạm AuthRepositoryImpl phòng trường hợp import chưa nhận ──
// Điều này giúp tránh lỗi compile nếu import vòng tròn.
class AuthRepositoryImplHelper {
  static AuthRepository create() => AuthRepositoryImpl();
}
