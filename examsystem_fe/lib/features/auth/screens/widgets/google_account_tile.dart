import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════════════════
// GoogleAccountTile — Widget hiển thị một Google account trong danh sách.
//
// Chuyển đổi pixel-perfect từ loginlikegooogle.txt:
//   <button class="account-item w-full flex items-center p-md ...">
//     <div class="w-10 h-10 rounded-full ..."> avatar </div>
//     <div class="flex flex-col ..."> name + email </div>
//   </button>
//
// Hỗ trợ:
//   ✅ Avatar ảnh hoặc chữ cái đầu (initial letter)
//   ✅ Tap callback
//   ✅ Scale animation khi nhấn (0.98) — đúng CSS .account-item:active
//   ✅ Background transition on hover/active
// ════════════════════════════════════════════════════════════════════════════
class GoogleAccountTile extends StatefulWidget {
  /// Tên hiển thị của account.
  final String displayName;

  /// Email của account.
  final String email;

  /// URL ảnh avatar (nullable — nếu null, hiển thị initial letter).
  final String? avatarUrl;

  /// Callback khi user tap vào account.
  final VoidCallback? onTap;

  /// Màu nền avatar khi không có ảnh (dùng cho initial letter).
  final Color? avatarBackgroundColor;

  const GoogleAccountTile({
    super.key,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.onTap,
    this.avatarBackgroundColor,
  });

  @override
  State<GoogleAccountTile> createState() => _GoogleAccountTileState();
}

class _GoogleAccountTileState extends State<GoogleAccountTile> {
  bool _isPressed = false;

  // ── Design tokens (đồng bộ HTML) ──────────────────────────────────────
  // bg-surface-container-lowest: #ffffff
  // border-surface-variant: #d3e4fe
  // hover:bg-surface-container-low: #eff4ff
  // active: scale(0.98) + bg-surface-container-highest: #d3e4fe
  // text-on-surface: #0b1c30
  // text-on-surface-variant: #5a4139
  static const _containerLowest = Color(0xFFFFFFFF);
  static const _surfaceVariant = Color(0xFFD3E4FE);
  static const _surfaceContainerHighest = Color(0xFFD3E4FE);
  static const _onSurface = Color(0xFF0B1C30);
  static const _onSurfaceVariant = Color(0xFF5A4139);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: double.infinity,
          padding: const EdgeInsets.all(16), // p-md: 16px
          decoration: BoxDecoration(
            color: _isPressed ? _surfaceContainerHighest : _containerLowest,
            borderRadius: BorderRadius.circular(8), // rounded-lg: 0.5rem
            border: Border.all(color: _surfaceVariant),
          ),
          child: Row(
            children: [
              // ── Avatar ─────────────────────────────────────────────────
              _buildAvatar(),
              const SizedBox(width: 12), // mr-sm: 12px

              // ── Name + Email ───────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // font-title-lg text-body-lg font-semibold text-on-surface
                    Text(
                      widget.displayName,
                      style: const TextStyle(
                        fontSize: 16,     // body-lg: 16px
                        fontWeight: FontWeight.w600, // font-semibold
                        color: _onSurface,
                        height: 1.5,      // lineHeight: 24px / 16px
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // font-body-md text-label-md text-on-surface-variant
                    Text(
                      widget.email,
                      style: const TextStyle(
                        fontSize: 12,     // label-md: 12px
                        fontWeight: FontWeight.w500, // label-md weight
                        letterSpacing: 0.6, // 0.05em ≈ 0.6px at 12px
                        color: _onSurfaceVariant,
                        height: 1.33,     // lineHeight: 16px / 12px
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Avatar: ảnh nếu có, initial letter nếu không.
  Widget _buildAvatar() {
    // w-10 h-10 rounded-full
    const double avatarSize = 40;

    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          widget.avatarUrl!,
          width: avatarSize,
          height: avatarSize,
          fit: BoxFit.cover,
          errorBuilder: (_, e, s) => _buildInitialAvatar(avatarSize),
        ),
      );
    }

    return _buildInitialAvatar(avatarSize);
  }

  /// Initial letter fallback avatar.
  Widget _buildInitialAvatar(double size) {
    final initial = widget.displayName.isNotEmpty
        ? widget.displayName[0].toUpperCase()
        : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // bg-tertiary-container: #447a9c (từ HTML cho account without image)
        color: widget.avatarBackgroundColor ?? const Color(0xFF447A9C),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 18,     // title-lg: 18px
            fontWeight: FontWeight.w600,
            // text-on-tertiary-container: #fcfcff
            color: const Color(0xFFFCFCFF),
          ),
        ),
      ),
    );
  }
}
