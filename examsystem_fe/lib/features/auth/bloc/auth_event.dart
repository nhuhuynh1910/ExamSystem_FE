// ════════════════════════════════════════════════════════════════════════════
// AuthEvent — Các sự kiện xác thực phát ra từ giao diện (UI).
// ════════════════════════════════════════════════════════════════════════════
abstract class AuthEvent {
  const AuthEvent();
}

/// Sự kiện người dùng nhấn nút "Sign In".
class LoginSubmitted extends AuthEvent {
  final String emailOrUsername;
  final String password;

  const LoginSubmitted({
    required this.emailOrUsername,
    required this.password,
  });
}

/// Sự kiện đăng xuất tài khoản.
class LogoutRequested extends AuthEvent {}
