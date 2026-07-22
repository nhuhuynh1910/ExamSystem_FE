// ════════════════════════════════════════════════════════════════════════════
// GoogleRegisterEvent — Các sự kiện trong luồng đăng ký bằng Google.
//
// Luồng 2 bước:
//   Bước 1: GoogleSignInRequested → mở popup Google → lấy profile
//   Bước 2: GoogleRegisterSubmitted → gửi API register với data Google + username
// ════════════════════════════════════════════════════════════════════════════
abstract class GoogleRegisterEvent {
  const GoogleRegisterEvent();
}

/// Bước 1: User nhấn nút "Register with Google" trên RegisterScreen.
///
/// GoogleRegisterBloc sẽ gọi Google Sign-In SDK để mở popup chọn tài khoản.
/// Kết quả: emit GoogleSignInSuccess (có profile) hoặc GoogleSignInFailure.
class GoogleSignInRequested extends GoogleRegisterEvent {
  const GoogleSignInRequested();
}

/// Bước 2: User nhấn nút "Complete Registration" trên GoogleCompleteRegistrationScreen.
///
/// Payload:
///   - [fullName]  → từ Google profile (read-only)
///   - [email]     → từ Google profile (read-only)
///   - [username]  → user tự nhập
///   - [role]      → 'Student' hoặc 'Teacher'
///   - [photoUrl]  → avatar từ Google (optional)
///
/// GoogleRegisterBloc sẽ:
///   1. Auto-gen password an toàn.
///   2. Gọi API POST /api/auth/register.
///   3. Emit GoogleRegisterSuccess hoặc GoogleRegisterFailure.
class GoogleRegisterSubmitted extends GoogleRegisterEvent {
  final String fullName;
  final String email;
  final String username;
  final String role;
  final String? photoUrl;

  const GoogleRegisterSubmitted({
    required this.fullName,
    required this.email,
    required this.username,
    this.role = 'Student',
    this.photoUrl,
  });
}
