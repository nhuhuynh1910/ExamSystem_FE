import 'package:shared_preferences/shared_preferences.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// StorageManager — Quản lý toàn bộ dữ liệu cục bộ (SharedPreferences).
///
/// Mục tiêu:
///   - Là nơi DUY NHẤT trong app đọc/ghi token và thông tin user vào bộ nhớ.
///   - Đồng bộ key với cấu trúc JSON BE trả về (AuthResponse.cs):
///       - AccessToken → lưu với key 'access_token'
///       - RefreshToken → lưu với key 'refresh_token'
///       - UserId, FullName, Email, Username, Role → lưu tương ứng.
///   - Mọi thành viên nhóm PHẢI dùng class này — không tự tạo key riêng.
///
/// Đặt tên key theo snake_case để dễ đọc và nhất quán.
/// ════════════════════════════════════════════════════════════════════════════
class StorageManager {
  // ── Định nghĩa các key lưu trữ ─────────────────────────────────────────────
  // Key token — đồng bộ với response JSON của BE (AuthResponse.cs):
  //   BE trả về: { "accessToken": "...", "refreshToken": "..." }
  //   Flutter dùng camelCase nhưng SharedPreferences lưu bằng snake_case để rõ ràng.
  static const String _keyAccessToken  = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';

  // Key thông tin người dùng (lấy từ AuthResponse.cs):
  //   UserId, FullName, Email, Username, Role
  static const String _keyUserId   = 'user_id';
  static const String _keyFullName = 'full_name';
  static const String _keyEmail    = 'email';
  static const String _keyUsername = 'username';
  static const String _keyRole     = 'role';

  // Key cài đặt ứng dụng (AppSettings):
  static const String _keyDarkMode          = 'setting_dark_mode';
  static const String _keyPushNotifications = 'setting_push_notifications';
  static const String _keyExamSound         = 'setting_exam_sound';
  static const String _keyVibration         = 'setting_vibration';
  static const String _keyLanguage          = 'setting_language';
  static const String _keyThemeColor        = 'setting_theme_color';
  static const String _keyBiometricLock     = 'setting_biometric_lock';

  // ════════════════════════════════════════════════════════════════════════════
  // PHẦN 1: LƯU DỮ LIỆU
  // ════════════════════════════════════════════════════════════════════════════

  /// Lưu toàn bộ thông tin auth sau khi đăng nhập thành công.
  ///
  /// Gọi hàm này ngay sau khi nhận AuthResponse từ BE:
  ///   await StorageManager.saveAuthData(
  ///     userId:       response.userId,
  ///     fullName:     response.fullName,
  ///     email:        response.email,
  ///     username:     response.username,
  ///     role:         response.role,
  ///     accessToken:  response.accessToken,
  ///     refreshToken: response.refreshToken,
  ///   );
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

    // Lưu từng trường vào SharedPreferences.
    await prefs.setInt   (_keyUserId,       userId);
    await prefs.setString(_keyFullName,     fullName);
    await prefs.setString(_keyEmail,        email);
    await prefs.setString(_keyUsername,     username);
    await prefs.setString(_keyRole,         role);
    await prefs.setString(_keyAccessToken,  accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  /// Lưu riêng cặp token mới sau khi refresh thành công.
  ///
  /// DioClient gọi hàm này sau khi BE cấp cặp token mới.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken,  accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PHẦN 2: ĐỌC DỮ LIỆU
  // ════════════════════════════════════════════════════════════════════════════

  /// Đọc Access Token (JWT ngắn hạn, dùng để gửi kèm mọi request API).
  ///
  /// BE kiểm tra trong header: Authorization: Bearer <accessToken>
  /// Trả về null nếu chưa đăng nhập.
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  /// Đọc Refresh Token (JWT dài hạn, dùng để xin cấp accessToken mới khi hết hạn).
  ///
  /// Trả về null nếu chưa đăng nhập.
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  /// Đọc UserId của người dùng hiện tại.
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  /// Đọc họ tên đầy đủ của người dùng (dùng để hiển thị trên UI).
  static Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFullName);
  }

  /// Đọc email của người dùng.
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  /// Đọc username của người dùng.
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  /// Đọc Role của người dùng.
  ///
  /// Các giá trị có thể: "Admin", "Teacher", "Student" (đồng bộ với BE).
  /// Dùng để phân quyền hiển thị UI (ví dụ: chỉ Teacher thấy nút tạo đề thi).
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PHẦN 3: KIỂM TRA TRẠNG THÁI
  // ════════════════════════════════════════════════════════════════════════════

  /// Kiểm tra xem người dùng đã đăng nhập chưa.
  ///
  /// Logic: có accessToken hợp lệ trong bộ nhớ → coi là đã đăng nhập.
  /// Lưu ý: hàm này KHÔNG kiểm tra token có còn hạn hay không.
  /// Việc kiểm tra hạn token do DioClient tự xử lý (refresh interceptor).
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PHẦN 4: XÓA DỮ LIỆU
  // ════════════════════════════════════════════════════════════════════════════

  /// Xóa toàn bộ dữ liệu auth (gọi khi người dùng đăng xuất).
  ///
  /// Sau khi xóa xong, AppRouter sẽ tự redirect về màn hình Login.
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    // Xóa từng key thay vì prefs.clear() để tránh xóa nhầm dữ liệu
    // của các module khác (nếu sau này có lưu thêm setting khác).
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyFullName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyRole);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PHẦN 5: ĐỌC & GHI CÀI ĐẶT ỨNG DỤNG (SETTINGS)
  // ════════════════════════════════════════════════════════════════════════════

  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  static Future<bool> getPushNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPushNotifications) ?? true;
  }

  static Future<void> setPushNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPushNotifications, value);
  }

  static Future<bool> getExamSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyExamSound) ?? true;
  }

  static Future<void> setExamSound(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyExamSound, value);
  }

  static Future<bool> getVibration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyVibration) ?? true;
  }

  static Future<void> setVibration(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVibration, value);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'Tiếng Việt (VN)';
  }

  static Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, lang);
  }

  static Future<String> getThemeColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeColor) ?? 'Cam Hổ Phách (Mặc định)';
  }

  static Future<void> setThemeColor(String colorName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeColor, colorName);
  }

  static Future<bool> getBiometricLock() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBiometricLock) ?? false;
  }

  static Future<void> setBiometricLock(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricLock, value);
  }
}
