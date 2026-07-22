/// Map từ ResetPasswordRequest.cs trong BE:
/// Token + NewPassword
class ResetPasswordRequest {
  final String token;
  final String newPassword;

  const ResetPasswordRequest({
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'token': token,
    'newPassword': newPassword,
  };
}
