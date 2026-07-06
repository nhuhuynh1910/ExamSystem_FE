/// ════════════════════════════════════════════════════════════════════════════
/// GoogleLoginRequest — Dữ liệu gửi lên BE để đăng nhập bằng Google.
///
/// Flow:
///   1. FE dùng Google Sign-In SDK lấy token từ Google.
///   2. FE gửi idToken + accessToken lên BE: POST /api/auth/google-login
///   3. BE ưu tiên verify idToken, fallback dùng accessToken gọi Google UserInfo API.
///   4. BE tìm user → trả AuthResponse (JWT).
///
/// Trên Flutter Web, idToken luôn null → BE dùng accessToken.
/// Trên native/mobile, idToken có giá trị → BE verify trực tiếp.
///
/// Đồng bộ với BE endpoint:
///   POST /api/auth/google-login
///   Body: { "idToken": "eyJ...", "accessToken": "ya29..." }
///   Response: AuthResponse (userId, fullName, email, accessToken, refreshToken)
/// ════════════════════════════════════════════════════════════════════════════
class GoogleLoginRequest {
  /// Google ID Token — JWT được Google cấp (null trên Web).
  final String idToken;

  /// Google Access Token — dùng khi idToken không có (Web fallback).
  final String? accessToken;

  const GoogleLoginRequest({
    required this.idToken,
    this.accessToken,
  });

  /// Chuyển thành JSON gửi lên BE.
  Map<String, dynamic> toJson() => {
    'idToken': idToken,
    if (accessToken != null && accessToken!.isNotEmpty)
      'accessToken': accessToken,
  };
}

