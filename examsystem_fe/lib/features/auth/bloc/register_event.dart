// ════════════════════════════════════════════════════════════════════════════
// RegisterEvent — Các sự kiện có thể xảy ra trong màn hình Đăng ký.
// ════════════════════════════════════════════════════════════════════════════
abstract class RegisterEvent {
  const RegisterEvent();
}

/// Người dùng nhấn nút "Create Account" sau khi điền form.
///
/// Payload:
///   - [fullName]  → tên đầy đủ
///   - [email]     → địa chỉ email
///   - [username]  → Student/Teacher ID (sẽ là username trong BE)
///   - [password]  → mật khẩu (đã pass validate ở UI)
///
/// Lưu ý: confirmPassword và role chỉ dùng cho validate/UI ở Flutter,
///        KHÔNG gửi lên Backend.
class RegisterSubmitted extends RegisterEvent {
  final String fullName;
  final String email;
  final String username;
  final String password;

  const RegisterSubmitted({
    required this.fullName,
    required this.email,
    required this.username,
    required this.password,
  });
}
