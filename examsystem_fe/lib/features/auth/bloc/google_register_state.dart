import '../data/google_auth_service.dart';

// ════════════════════════════════════════════════════════════════════════════
// GoogleRegisterState — Các trạng thái trong luồng đăng ký bằng Google.
//
// Luồng trạng thái:
//   GoogleRegisterInitial
//     ↓ (GoogleSignInRequested)
//   GoogleSignInLoading
//     ├── GoogleSignInSuccess(profile) → navigate sang Complete Registration
//     └── GoogleSignInFailure(error)   → hiển thị lỗi
//
//   GoogleSignInSuccess
//     ↓ (GoogleRegisterSubmitted)
//   GoogleRegisterLoading
//     ├── GoogleRegisterSuccess(message) → dialog thành công → về Login
//     └── GoogleRegisterFailure(error)   → hiển thị lỗi
// ════════════════════════════════════════════════════════════════════════════
abstract class GoogleRegisterState {
  const GoogleRegisterState();
}

/// Trạng thái ban đầu — chưa bắt đầu luồng Google.
class GoogleRegisterInitial extends GoogleRegisterState {
  const GoogleRegisterInitial();
}

// ── Bước 1: Google Sign-In ────────────────────────────────────────────────

/// Đang hiển thị popup Google Sign-In — loading.
class GoogleSignInLoading extends GoogleRegisterState {
  const GoogleSignInLoading();
}

/// Google Sign-In thành công — có profile để hiển thị trên Complete Registration.
///
/// [profile] chứa fullName, email, photoUrl từ Google.
/// UI sẽ navigate sang GoogleCompleteRegistrationScreen với data này.
class GoogleSignInSuccess extends GoogleRegisterState {
  final GoogleUserProfile profile;

  const GoogleSignInSuccess(this.profile);
}

/// Google Sign-In thất bại hoặc user hủy.
class GoogleSignInFailure extends GoogleRegisterState {
  final String errorMessage;

  const GoogleSignInFailure(this.errorMessage);
}

// ── Bước 2: Gọi API Register ─────────────────────────────────────────────

/// Đang gọi API đăng ký — loading indicator trên nút Complete Registration.
class GoogleRegisterLoading extends GoogleRegisterState {
  const GoogleRegisterLoading();
}

/// Đăng ký thành công.
///
/// [message] là message từ BE:
///   "Đăng ký thành công. Vui lòng kiểm tra email để xác nhận tài khoản."
class GoogleRegisterSuccess extends GoogleRegisterState {
  final String message;

  const GoogleRegisterSuccess(this.message);
}

/// Đăng ký thất bại (email trùng, lỗi server, v.v.).
class GoogleRegisterFailure extends GoogleRegisterState {
  final String errorMessage;
  final bool requiresEmailVerification;

  const GoogleRegisterFailure(
    this.errorMessage, {
    this.requiresEmailVerification = false,
  });
}
