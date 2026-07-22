/// Map từ ForgotPasswordRequest.cs trong BE:
/// Email
class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {
    'email': email,
  };
}
