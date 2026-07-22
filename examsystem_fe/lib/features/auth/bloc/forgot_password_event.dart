// ════════════════════════════════════════════════════════════════════════════
// ForgotPasswordEvent — Các sự kiện có thể xảy ra trong màn hình Quên mật khẩu.
// ════════════════════════════════════════════════════════════════════════════
abstract class ForgotPasswordEvent {
  const ForgotPasswordEvent();
}

/// Người dùng nhấn nút "Send Reset Link" sau khi nhập email.
class ForgotPasswordSubmitted extends ForgotPasswordEvent {
  final String email;

  const ForgotPasswordSubmitted({required this.email});
}
