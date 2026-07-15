// ════════════════════════════════════════════════════════════════════════════
// ForgotPasswordState — Các trạng thái có thể có của màn hình Quên mật khẩu.
// ════════════════════════════════════════════════════════════════════════════
abstract class ForgotPasswordState {
  const ForgotPasswordState();
}

/// Trạng thái ban đầu — form rỗng, chưa có hành động nào.
class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

/// Đang gọi API — hiển thị loading indicator, disable các nút.
class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

/// Gửi yêu cầu thành công.
///
/// [message] là message từ BE:
///   "Nếu email tồn tại trong hệ thống, chúng tôi đã gửi link đặt lại mật khẩu."
///
/// [email] để hiển thị cho user biết email nào đã được gửi link.
class ForgotPasswordSuccess extends ForgotPasswordState {
  final String message;
  final String email;

  const ForgotPasswordSuccess({required this.message, required this.email});
}

/// Gửi yêu cầu thất bại.
///
/// [errorMessage] là message lỗi đã được xử lý, hiển thị trực tiếp lên UI.
class ForgotPasswordFailure extends ForgotPasswordState {
  final String errorMessage;

  const ForgotPasswordFailure(this.errorMessage);
}
