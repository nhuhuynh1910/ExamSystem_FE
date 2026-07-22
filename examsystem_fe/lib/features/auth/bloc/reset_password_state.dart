// ════════════════════════════════════════════════════════════════════════════
// ResetPasswordState — Các trạng thái có thể có của màn hình Đặt lại mật khẩu.
// ════════════════════════════════════════════════════════════════════════════
abstract class ResetPasswordState {
  const ResetPasswordState();
}

/// Trạng thái ban đầu — form rỗng, chưa có hành động nào.
class ResetPasswordInitial extends ResetPasswordState {
  const ResetPasswordInitial();
}

/// Đang gọi API — hiển thị loading indicator, disable các nút.
class ResetPasswordLoading extends ResetPasswordState {
  const ResetPasswordLoading();
}

/// Đặt lại mật khẩu thành công.
///
/// [message] là message từ BE:
///   "Đặt lại mật khẩu thành công. Vui lòng đăng nhập bằng mật khẩu mới."
///
/// UI sẽ hiển thị success rồi chuyển về màn hình Login.
class ResetPasswordSuccess extends ResetPasswordState {
  final String message;

  const ResetPasswordSuccess(this.message);
}

/// Đặt lại mật khẩu thất bại.
///
/// [errorMessage] là message lỗi đã được xử lý, hiển thị trực tiếp lên UI.
class ResetPasswordFailure extends ResetPasswordState {
  final String errorMessage;

  const ResetPasswordFailure(this.errorMessage);
}
