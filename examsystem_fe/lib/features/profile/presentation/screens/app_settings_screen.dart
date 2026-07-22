import 'package:flutter/material.dart';
import '../../../../core/settings/app_settings_notifier.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// AppSettingsScreen — Màn hình Cài đặt Ứng dụng (THỰC SỰ HOẠT ĐỘNG).
///
/// Tích hợp AppSettingsNotifier (global state):
/// - Đọc state từ AppSettings.notifier (đã load từ SharedPreferences khi khởi động).
/// - Mỗi thay đổi → gọi notifier setter → tự động lưu + notifyListeners()
///   → MaterialApp rebuild → Dark Mode / ThemeColor áp dụng NGAY cho toàn app.
/// ════════════════════════════════════════════════════════════════════════════
class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _clearCache(BuildContext context, bool isDark) {
    final imageCache = PaintingBinding.instance.imageCache;
    final currentMB = (imageCache.currentSizeBytes / (1024 * 1024));

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.cleaning_services_rounded, color: Color(0xFFF15A22)),
            SizedBox(width: 10),
            Text(
              'Clear cache?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'This action will free ${currentMB.toStringAsFixed(1)} MB of image cache memory without affecting your account.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              PaintingBinding.instance.imageCache.clear();
              PaintingBinding.instance.imageCache.clearLiveImages();
              _showSnackBar(context, 'Image cache cleared successfully!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF15A22),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Clear Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder: rebuild màn hình này mỗi khi settings thay đổi.
    // Ví dụ: bật Dark Mode → màn hình Settings cũng đổi màu ngay lập tức.
    return ListenableBuilder(
      listenable: AppSettings.notifier,
      builder: (context, _) {
        final notifier = AppSettings.notifier;
        final isDark = notifier.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : const Color(0xFF1D3557),
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'App Settings',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1D3557),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── SECTION 1: GIAO DIỆN & MÀU SẮC ─────────────────────────
                _buildSectionHeader('THEME & APPEARANCE', Icons.palette_rounded, isDark),
                const SizedBox(height: 8),
                _buildCard(isDark, [
                  _buildSwitch(
                    isDark: isDark,
                    icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    title: 'Dark Mode',
                    subtitle: 'Use darker theme to reduce eye strain',
                    value: notifier.isDarkMode,
                    onChanged: (val) async {
                      await notifier.setDarkMode(val);
                    },
                  ),
                  _divider(),
                  _buildDropdown(
                    isDark: isDark,
                    icon: Icons.color_lens_rounded,
                    iconColor: const Color(0xFFF15A22),
                    title: 'Primary Theme Color',
                    value: notifier.themeColor,
                    options: const [
                      'Amber Orange (Default)',
                      'Ocean Navy',
                      'Emerald Green',
                    ],
                    onChanged: (val) async {
                      if (val != null) await notifier.setThemeColor(val);
                    },
                  ),
                ]),

                const SizedBox(height: 24),

                // ── SECTION 2: THÔNG BÁO & ÂM THANH ────────────────────────
                _buildSectionHeader('NOTIFICATIONS & SOUND', Icons.notifications_active_rounded, isDark),
                const SizedBox(height: 8),
                _buildCard(isDark, [
                  _buildSwitch(
                    isDark: isDark,
                    icon: Icons.notifications_none_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    title: 'Push Notifications',
                    subtitle: 'Receive notifications for new exams and results',
                    value: notifier.pushNotifications,
                    onChanged: (val) async => notifier.setPushNotifications(val),
                  ),
                  _divider(),
                  _buildSwitch(
                    isDark: isDark,
                    icon: Icons.volume_up_rounded,
                    iconColor: const Color(0xFF10B981),
                    title: 'Countdown Sound',
                    subtitle: 'Play sound when exam has 5 minutes remaining',
                    value: notifier.examSound,
                    onChanged: (val) async => notifier.setExamSound(val),
                  ),
                  _divider(),
                  _buildSwitch(
                    isDark: isDark,
                    icon: Icons.vibration_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'Vibration on Submission',
                    subtitle: 'Vibrate device upon completing exam submission',
                    value: notifier.vibration,
                    onChanged: (val) async => notifier.setVibration(val),
                  ),
                ]),

                const SizedBox(height: 24),

                // ── SECTION 3: CẤU HÌNH CHUNG & BẢO MẬT ────────────────────
                _buildSectionHeader('GENERAL & SECURITY', Icons.tune_rounded, isDark),
                const SizedBox(height: 8),
                _buildCard(isDark, [
                  _buildDropdown(
                    isDark: isDark,
                    icon: Icons.language_rounded,
                    iconColor: const Color(0xFF06B6D4),
                    title: 'App Language',
                    value: notifier.language,
                    options: const ['Vietnamese (VN)', 'English (US)'],
                    onChanged: (val) async {
                      if (val != null) await notifier.setLanguage(val);
                    },
                  ),
                  _divider(),
                  _buildSwitch(
                    isDark: isDark,
                    icon: Icons.fingerprint_rounded,
                    iconColor: const Color(0xFFEC4899),
                    title: 'Biometric Lock (Fingerprint / FaceID)',
                    subtitle: 'Require biometric security when opening app',
                    value: notifier.biometricLock,
                    onChanged: (val) async => notifier.setBiometricLock(val),
                  ),
                ]),

                const SizedBox(height: 24),

                // ── SECTION 4: BỘ NHỚ & DỮ LIỆU ────────────────────────────
                _buildSectionHeader('STORAGE & LOCAL DATA', Icons.storage_rounded, isDark),
                const SizedBox(height: 8),
                _buildCard(isDark, [
                  _buildActionTile(
                    isDark: isDark,
                    icon: Icons.cleaning_services_rounded,
                    iconColor: const Color(0xFFEF4444),
                    title: 'Clear Cache',
                    subtitle: 'Free memory used by cached images',
                    actionLabel: 'Clear Now',
                    onTap: () => _clearCache(context, isDark),
                  ),
                ]),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Helper Builders ────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFFF15A22)),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() => const Divider(color: Color(0xFFF3F4F6), height: 1);

  Widget _buildSwitch({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _iconBadge(icon, iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1D3557),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _iconBadge(icon, iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1D3557),
              ),
            ),
          ),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF9CA3AF)),
            dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFF15A22),
              fontWeight: FontWeight.bold,
            ),
            items: options.map((opt) => DropdownMenuItem(
              value: opt,
              child: Text(
                opt,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                  fontSize: 13,
                ),
              ),
            )).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _iconBadge(icon, iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1D3557),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                actionLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
