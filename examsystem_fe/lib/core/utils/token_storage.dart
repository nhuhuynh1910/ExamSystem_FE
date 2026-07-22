import 'package:shared_preferences/shared_preferences.dart';

/// Quản lý lưu / lấy / xoá token JWT và thông tin user cơ bản.
/// Tất cả thành viên nhóm đều dùng class này — không ai tự lưu token riêng.
class TokenStorage {
  static const _keyAccessToken  = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId       = 'user_id';
  static const _keyFullName     = 'full_name';
  static const _keyEmail        = 'email';
  static const _keyUsername     = 'username';
  static const _keyRole         = 'role';

  // ── Lưu toàn bộ thông tin sau khi login thành công ─────────────────────────
  static Future<void> saveAuthData({
    required int    userId,
    required String fullName,
    required String email,
    required String username,
    required String role,
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt   (_keyUserId,       userId);
    await prefs.setString(_keyFullName,     fullName);
    await prefs.setString(_keyEmail,        email);
    await prefs.setString(_keyUsername,     username);
    await prefs.setString(_keyRole,         role);
    await prefs.setString(_keyAccessToken,  accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  // ── Lấy token ──────────────────────────────────────────────────────────────
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  // ── Lấy thông tin user ──────────────────────────────────────────────────────
  static Future<String?> getRole()     async => (await SharedPreferences.getInstance()).getString(_keyRole);
  static Future<String?> getFullName() async => (await SharedPreferences.getInstance()).getString(_keyFullName);
  static Future<int?>    getUserId()   async => (await SharedPreferences.getInstance()).getInt(_keyUserId);

  // ── Kiểm tra đã đăng nhập chưa ─────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ── Xoá toàn bộ khi logout ─────────────────────────────────────────────────
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
