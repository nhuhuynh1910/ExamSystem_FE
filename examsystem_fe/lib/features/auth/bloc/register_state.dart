// ════════════════════════════════════════════════════════════════════════════
// RegisterState — Các trạng thái có thể có của màn hình Đăng ký.
// ════════════════════════════════════════════════════════════════════════════
abstract class RegisterState {
  const RegisterState();
}

/// Trạng thái ban đầu — form rỗng, chưa có hành động nào.
class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

/// Đang gọi API — hiển thị loading indicator, disable các nút.
class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

/// Đăng ký thành công.
///
/// [message] là message từ BE:
///   "Đăng ký thành công. Vui lòng kiểm tra email để xác nhận tài khoản."
///
/// UI sẽ hiển thị dialog xác nhận email rồi chuyển về màn hình Login.
class RegisterSuccess extends RegisterState {
  final String message;

  const RegisterSuccess(this.message);
}

/// Đăng ký thất bại.
///
/// [errorMessage] là message lỗi đã được xử lý, hiển thị trực tiếp lên UI.
/// [requiresEmailVerification] = true khi email đã đăng ký nhưng chưa xác nhận.
class RegisterFailure extends RegisterState {
  final String errorMessage;
  final bool requiresEmailVerification;

  const RegisterFailure(
    this.errorMessage, {
    this.requiresEmailVerification = false,
  });
}
