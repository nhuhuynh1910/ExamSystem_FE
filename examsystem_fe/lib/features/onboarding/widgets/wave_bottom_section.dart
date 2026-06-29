import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';

// ════════════════════════════════════════════════════════════════════════════
// WaveBottomSection — Phần dưới màn hình Onboarding với wave shape.
//
// Lấy từ HTML:
//   .wave-shape { clip-path: polygon(0 15%, 100% 0, 100% 100%, 0 100%); }
//   background:  surface-container (#e5eeff)
//
// Nội dung bên trong wave:
//   - Button "Get Started" → navigate /login
//   - Text "Already have an account? Log in" → navigate /login
// ════════════════════════════════════════════════════════════════════════════
class WaveBottomSection extends StatelessWidget {
  const WaveBottomSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      // Wave shape: đồng bộ với .wave-shape CSS polygon.
      // HTML: clip-path: polygon(0 15%, 100% 0, 100% 100%, 0 100%)
      // → Góc trên-trái cắt vào 15%, góc trên-phải ở 0% (thẳng).
      clipper: _WaveClipper(),
      child: Container(
        // Màu nền: surface-container (#e5eeff) — đồng bộ với HTML.
        color: const Color(0xFFE5EEFF),
        padding: const EdgeInsets.only(
          top: 56, // Bù cho phần bị cắt bởi wave
          left: 24,
          right: 24,
          bottom: 40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Button "Get Started" ────────────────────────────────────────
            // → Navigate /login (Button Login trong requirements)
            // HTML: nút chính với màu primary
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.go(AppRouter.login),
                style: ElevatedButton.styleFrom(
                  // Màu: primary #F15A22 — đồng bộ với HTML.
                  backgroundColor: const Color(0xFFF15A22),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26), // border-radius: full (9999px)
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── "Already have an account? Log in" ──────────────────────────
            // → Navigate /login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF0B1C30).withValues(alpha: 0.7), // on-background mờ
                    fontWeight: FontWeight.w400,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go(AppRouter.login),
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFF15A22), // primary: #F15A22
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFFF15A22),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _WaveClipper — CustomClipper tạo wave shape từ HTML polygon.
//
// HTML: clip-path: polygon(0 15%, 100% 0, 100% 100%, 0 100%)
//
// Điểm tọa độ (tính theo tỉ lệ width x height):
//   (0%, 15%)  → góc trên-trái, cắt vào 15% chiều cao
//   (100%, 0%) → góc trên-phải, ở đỉnh (0%)
//   (100%, 100%) → góc dưới-phải
//   (0%, 100%) → góc dưới-trái
// Kết quả: hình thang xiên tạo hiệu ứng "sóng" nghiêng.
// ════════════════════════════════════════════════════════════════════════════
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Đồng bộ 100% với CSS: polygon(0 15%, 100% 0, 100% 100%, 0 100%)
    path.moveTo(0, size.height * 0.15); // (0%, 15%)
    path.lineTo(size.width, 0);         // (100%, 0%)
    path.lineTo(size.width, size.height); // (100%, 100%)
    path.lineTo(0, size.height);          // (0%, 100%)
    path.close();

    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => false;
}
