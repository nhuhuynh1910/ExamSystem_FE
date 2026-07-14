/// DTO gửi lên BE khi đổi mật khẩu.
///
/// OldPassword có thể null nếu user Google-only (chưa có password).
class ChangePasswordRequest {
  final String? oldPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordRequest({
    this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      if (oldPassword != null) 'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}
