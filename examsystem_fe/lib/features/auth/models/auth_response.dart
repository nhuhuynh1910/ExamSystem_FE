class AuthResponse {
  final int userId;
  final String fullName;
  final String email;
  final String username;
  final String role;
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.username,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }
}
