/// Map từ AuthResponse.cs trong BE:
/// UserId, FullName, Email, Username, Role, AccessToken, RefreshToken
class AuthResponse {
  final int    userId;
  final String fullName;
  final String email;
  final String username;
  final String role;
  final String accessToken;
  final String refreshToken;

  const AuthResponse({
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
      userId:       json['userId']       as int,
      fullName:     json['fullName']     as String,
      email:        json['email']        as String,
      username:     json['username']     as String,
      role:         json['role']         as String,
      accessToken:  json['accessToken']  as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}
