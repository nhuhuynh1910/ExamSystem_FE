import '../models/auth_response.dart';

// ════════════════════════════════════════════════════════════════════════════
// AuthState — Các trạng thái nghiệp vụ của quá trình xác thực.
// ════════════════════════════════════════════════════════════════════════════
abstract class AuthState {
  const AuthState();
}

/// Trạng thái ban đầu.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Trạng thái đang gọi API (hiển thị loading indicator).
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Đăng nhập thành công, chứa thông tin phiên làm việc từ Backend.
class AuthSuccess extends AuthState {
  final AuthResponse response;

  const AuthSuccess(this.response);
}

/// Đăng nhập thất bại, chứa thông báo lỗi để hiển thị lên UI.
class AuthFailure extends AuthState {
  final String errorMessage;

  const AuthFailure(this.errorMessage);
}
