/// Map từ RegisterRequest.cs trong BE:
/// FullName, Email, Username, Password (>=6 ký tự, có chữ + số + ký tự đặc biệt), Role
class RegisterRequest {
  final String fullName;
  final String email;
  final String username;
  final String password;

  /// Role đăng ký: 'Student' (default) hoặc 'Teacher'.
  final String role;

  final String? avatarUrl;

  const RegisterRequest({
    required this.fullName,
    required this.email,
    required this.username,
    required this.password,
    this.role = 'Student',
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email':    email,
    'username': username,
    'password': password,
    'role':     role,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
  };
}
