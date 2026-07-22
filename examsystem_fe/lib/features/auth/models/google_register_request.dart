/// ════════════════════════════════════════════════════════════════════════════
/// GoogleRegisterRequest — Dữ liệu đăng ký từ luồng Google Sign-In.
///
/// Chứa thông tin profile từ Google (read-only) + input từ user (username).
/// Password được tự động sinh vì BE bắt buộc trường này nhưng Google user
/// không cần nhập mật khẩu.
///
/// Khi gửi lên BE, dùng [toRegisterJson()] để chuyển về format
/// đồng bộ với RegisterRequest.cs:
///   { "fullName", "email", "username", "password" }
/// ════════════════════════════════════════════════════════════════════════════
class GoogleRegisterRequest {
  /// Tên đầy đủ từ Google profile (read-only, user không chỉnh sửa).
  final String fullName;

  /// Email từ Google profile (read-only, user không chỉnh sửa).
  final String email;

  /// Username do user tự nhập trên màn hình Complete Registration.
  /// BE yêu cầu unique, max 100 ký tự.
  final String username;

  /// Mật khẩu tự động sinh (UUID-based + special chars).
  /// User không cần biết vì đăng nhập qua Google.
  final String password;

  /// URL avatar từ Google (dùng để hiển thị trên UI, không gửi lên BE).
  final String? photoUrl;

  const GoogleRegisterRequest({
    required this.fullName,
    required this.email,
    required this.username,
    required this.password,
    this.photoUrl,
  });

  /// Chuyển thành JSON đồng bộ với BE RegisterRequest.cs.
  ///
  /// BE chỉ nhận 4 trường: fullName, email, username, password.
  /// photoUrl KHÔNG gửi lên BE.
  Map<String, dynamic> toRegisterJson() => {
    'fullName': fullName,
    'email': email,
    'username': username,
    'password': password,
  };
}
