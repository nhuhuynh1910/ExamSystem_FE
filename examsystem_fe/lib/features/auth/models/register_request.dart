/// Map từ RegisterRequest.cs trong BE:
/// FullName, Email, Username, Password (>=6 ký tự, có chữ + số + ký tự đặc biệt)
class RegisterRequest {
  final String fullName;
  final String email;
  final String username;
  final String password;

  const RegisterRequest({
    required this.fullName,
    required this.email,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email':    email,
    'username': username,
    'password': password,
  };
}
