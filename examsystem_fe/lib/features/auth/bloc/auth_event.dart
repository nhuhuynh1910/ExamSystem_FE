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

/// Sự kiện đăng nhập bằng Google.
///
/// Chứa idToken và/hoặc accessToken từ Google Sign-In SDK.
/// AuthBloc sẽ gọi authRepository.googleLogin() để verify với BE.
///
/// Trên Web: idToken rỗng, accessToken có giá trị.
/// Trên native: idToken có giá trị, accessToken optional.
class GoogleLoginSubmitted extends AuthEvent {
  /// Google ID Token — JWT được Google cấp cho FE (rỗng trên Web).
  final String idToken;

  /// Google Access Token — fallback cho Web khi idToken null.
  final String? accessToken;

  const GoogleLoginSubmitted({required this.idToken, this.accessToken});
}
