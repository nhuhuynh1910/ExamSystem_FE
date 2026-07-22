import 'package:flutter/material.dart';
import '../utils/storage_manager.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// AppSettingsNotifier — Global Settings State (ChangeNotifier)
///
/// Là nguồn sự thật DUY NHẤT cho toàn bộ cài đặt ứng dụng.
///
/// Cách hoạt động:
///   1. main() khởi tạo và gọi loadFromStorage() để đọc cài đặt đã lưu.
///   2. main.dart dùng ListenableBuilder để lắng nghe thay đổi.
///   3. Khi user đổi cài đặt (vd: Dark Mode), setter gọi notifyListeners()
///      → MaterialApp rebuild với theme mới → áp dụng toàn bộ app ngay lập tức.
/// ════════════════════════════════════════════════════════════════════════════
class AppSettingsNotifier extends ChangeNotifier {
  // ── Private state ──────────────────────────────────────────────────────────
  bool _isDarkMode = false;
  bool _pushNotifications = true;
  bool _examSound = true;
  bool _vibration = true;
  String _language = 'Vietnamese (VN)';
  String _themeColor = 'Amber Orange (Default)';
  bool _biometricLock = false;

  // ── Public getters ─────────────────────────────────────────────────────────
  bool get isDarkMode => _isDarkMode;
  bool get pushNotifications => _pushNotifications;
  bool get examSound => _examSound;
  bool get vibration => _vibration;
  String get language => _language;
  String get themeColor => _themeColor;
  bool get biometricLock => _biometricLock;

  /// ThemeMode hiện tại — dùng trực tiếp trong MaterialApp.themeMode
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Màu primary tương ứng với themeColor đã chọn
  Color get primaryColor {
    switch (_themeColor) {
      case 'Ocean Navy':
      case 'Xanh Băng Xanh (Ocean Navy)':
        return const Color(0xFF1E40AF);
      case 'Emerald Green':
      case 'Lục Bảo (Emerald)':
        return const Color(0xFF059669);
      case 'Amber Orange (Default)':
      case 'Cam Hổ Phách (Mặc định)':
      default:
        return const Color(0xFFF15A22);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // KHỞI TẠO — Đọc tất cả cài đặt từ SharedPreferences khi app bắt đầu
  // ══════════════════════════════════════════════════════════════════════════

  /// Gọi hàm này trong main() trước runApp() để load cài đặt đã lưu.
  Future<void> loadFromStorage() async {
    _isDarkMode        = await StorageManager.getDarkMode();
    _pushNotifications = await StorageManager.getPushNotifications();
    _examSound         = await StorageManager.getExamSound();
    _vibration         = await StorageManager.getVibration();
    
    final rawLang      = await StorageManager.getLanguage();
    if (rawLang == 'Tiếng Việt (VN)') {
      _language = 'Vietnamese (VN)';
    } else if (rawLang == 'English (US)' || rawLang == 'Vietnamese (VN)') {
      _language = rawLang;
    } else {
      _language = 'Vietnamese (VN)';
    }

    final rawColor     = await StorageManager.getThemeColor();
    if (rawColor == 'Cam Hổ Phách (Mặc định)') {
      _themeColor = 'Amber Orange (Default)';
    } else if (rawColor == 'Xanh Băng Xanh (Ocean Navy)') {
      _themeColor = 'Ocean Navy';
    } else if (rawColor == 'Lục Bảo (Emerald)') {
      _themeColor = 'Emerald Green';
    } else if (['Amber Orange (Default)', 'Ocean Navy', 'Emerald Green'].contains(rawColor)) {
      _themeColor = rawColor;
    } else {
      _themeColor = 'Amber Orange (Default)';
    }

    _biometricLock     = await StorageManager.getBiometricLock();
    // Không notifyListeners() ở đây vì widget tree chưa được tạo
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SETTERS — Lưu vào SharedPreferences rồi notifyListeners() để rebuild app
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await StorageManager.setDarkMode(value);
    notifyListeners(); // → MaterialApp rebuild với ThemeMode mới
  }

  Future<void> setPushNotifications(bool value) async {
    _pushNotifications = value;
    await StorageManager.setPushNotifications(value);
    notifyListeners();
  }

  Future<void> setExamSound(bool value) async {
    _examSound = value;
    await StorageManager.setExamSound(value);
    notifyListeners();
  }

  Future<void> setVibration(bool value) async {
    _vibration = value;
    await StorageManager.setVibration(value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    await StorageManager.setLanguage(value);
    notifyListeners();
  }

  Future<void> setThemeColor(String value) async {
    _themeColor = value;
    await StorageManager.setThemeColor(value);
    notifyListeners(); // → MaterialApp rebuild với primaryColor mới
  }

  Future<void> setBiometricLock(bool value) async {
    _biometricLock = value;
    await StorageManager.setBiometricLock(value);
    notifyListeners();
  }
}

/// ════════════════════════════════════════════════════════════════════════════
/// AppSettings — Singleton toàn cục, truy cập từ bất kỳ đâu trong app.
///
/// Dùng: AppSettings.notifier.isDarkMode
///       await AppSettings.notifier.setDarkMode(true)
///
/// Đặt tại đây (KHÔNG trong main.dart) để tránh circular import.
/// ════════════════════════════════════════════════════════════════════════════
class AppSettings {
  AppSettings._(); // private constructor — không cho new
  static final AppSettingsNotifier notifier = AppSettingsNotifier();
}
