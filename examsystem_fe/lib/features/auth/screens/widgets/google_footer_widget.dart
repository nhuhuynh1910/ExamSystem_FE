import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════════════════
// GoogleFooterWidget — Privacy notice + links ở cuối Account Picker.
//
// Chuyển đổi pixel-perfect từ loginlikegooogle.txt:
//   <div class="mt-auto pt-xl ...">
//     <p ...>To continue, Google will share your name, email address...</p>
//     <div ...>Privacy Policy · Terms of Service</div>
//   </div>
//
// Tách riêng để tái sử dụng nếu cần ở màn hình Google khác.
// ════════════════════════════════════════════════════════════════════════════
class GoogleFooterWidget extends StatelessWidget {
  /// Tên ứng dụng hiển thị trong notice text.
  final String appName;

  const GoogleFooterWidget({
    super.key,
    this.appName = 'FPT ExamHub',
  });

  // Design tokens (đồng bộ HTML)
  // text-on-surface-variant: #5a4139
  // text-primary: #a83300
  static const _onSurfaceVariant = Color(0xFF5A4139);
  static const _primary = Color(0xFFA83300);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Notice text ────────────────────────────────────────────────
        // font-body-md text-label-md text-on-surface-variant max-w-[280px]
        SizedBox(
          width: 280,
          child: Text(
            'To continue, Google will share your name, email address, '
            'and profile picture with $appName.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,       // label-md: 12px
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6, // 0.05em
              color: _onSurfaceVariant,
              height: 1.33,       // 16px / 12px
            ),
          ),
        ),

        const SizedBox(height: 12), // mt-sm: 12px

        // ── Privacy Policy + Terms ─────────────────────────────────────
        // <div class="flex items-center justify-center gap-md mt-sm">
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Privacy Policy link
            GestureDetector(
              onTap: () {
                // TODO: Open Privacy Policy URL
              },
              child: const Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 12,       // label-md
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.6,
                  color: _primary,
                ),
              ),
            ),

            // Dot separator (w-[4px] h-[4px] rounded-full bg-on-surface-variant)
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 16), // gap-md: 16px
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _onSurfaceVariant,
              ),
            ),

            // Terms of Service link
            GestureDetector(
              onTap: () {
                // TODO: Open Terms of Service URL
              },
              child: const Text(
                'Terms of Service',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.6,
                  color: _primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
