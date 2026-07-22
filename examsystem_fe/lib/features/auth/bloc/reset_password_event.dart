// ════════════════════════════════════════════════════════════════════════════
// ResetPasswordEvent — Các sự kiện có thể xảy ra trong màn hình Đặt lại mật khẩu.
// ════════════════════════════════════════════════════════════════════════════
abstract class ResetPasswordEvent {
  const ResetPasswordEvent();
}

/// Người dùng nhấn nút "Reset Password" sau khi nhập mật khẩu mới.
class ResetPasswordSubmitted extends ResetPasswordEvent {
  final String token;
  final String newPassword;

  const ResetPasswordSubmitted({
    required this.token,
    required this.newPassword,
  });
}
