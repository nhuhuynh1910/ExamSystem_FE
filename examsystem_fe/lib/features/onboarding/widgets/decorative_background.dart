import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════════════════
// DecorativeBackground — 4 vòng tròn/chấm nổi với float animation.
//
// Lấy từ HTML:
//   .decorative-circle { animation: float 8s ease-in-out infinite; }
//   .decorative-dot    { animation: float 6s ease-in-out infinite reverse; }
//
//   @keyframes float {
//     0%   { transform: translateY(0px) translateX(0px); }
//     50%  { transform: translateY(-20px) translateX(10px); }
//     100% { transform: translateY(0px) translateX(0px); }
//   }
//
// 4 phần tử (đồng bộ với HTML):
//   1. Circle top-left:    w-32 h-32 (128px), opacity 15%
//   2. Dot top-right:      w-4 h-4 (16px),  opacity 15%
//   3. Circle mid-right:   w-48 h-48 (192px), opacity 15%
//   4. Dot bottom-left:    w-3 h-3 (12px),  opacity 15%
// ════════════════════════════════════════════════════════════════════════════
class DecorativeBackground extends StatefulWidget {
  const DecorativeBackground({super.key});

  @override
  State<DecorativeBackground> createState() => _DecorativeBackgroundState();
}

class _DecorativeBackgroundState extends State<DecorativeBackground>
    with TickerProviderStateMixin {
  // Circle animation: 8s, ease-in-out, infinite (đồng bộ với .decorative-circle CSS).
  late final AnimationController _circleController;

  // Dot animation: 6s, ease-in-out, infinite reverse (đồng bộ với .decorative-dot CSS).
  late final AnimationController _dotController;

  late final Animation<double> _circleAnim;
  late final Animation<double> _dotAnim;

  @override
  void initState() {
    super.initState();

    // ── Circle controller: 8 giây, lặp vô tận ──────────────────────────────
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true); // reverse: true tương đương infinite alternate

    // ── Dot controller: 6 giây, lặp reverse (đảo chiều) ───────────────────
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    // Curve: easeInOut — đồng bộ với CSS ease-in-out.
    _circleAnim = CurvedAnimation(
      parent: _circleController,
      curve: Curves.easeInOut,
    );
    _dotAnim = CurvedAnimation(
      parent: _dotController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _circleController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: Listenable.merge([_circleAnim, _dotAnim]),
      builder: (context, child) {
        // float animation:
        //   translateY: 0 → -20px → 0   (lên rồi về)
        //   translateX: 0 →  10px → 0   (sang phải rồi về)
        // Dùng sin/cos để tạo chuyển động mượt đồng bộ với CSS.
        final double circleY = -20 * _circleAnim.value;
        final double circleX = 10 * _circleAnim.value;

        // Dot đảo ngược nên animation value ngược lại (đã xử lý bằng reverse: true).
        final double dotY = -20 * _dotAnim.value;
        final double dotX = 10 * _dotAnim.value;

        return Stack(
          children: [
            // ── 1. Circle top-left: absolute top-[10%] -left-10 w-32 h-32 ──
            // HTML: top: 10%, left: -40px (approx -left-10 = -2.5rem)
            Positioned(
              top: size.height * 0.10 + circleY,
              left: -40 + circleX,
              child: _DecorativeCircle(size: 128),
            ),

            // ── 2. Dot top-right: absolute top-[25%] right-10 w-4 h-4 ──────
            // HTML: top: 25%, right: 40px (right-10 = 2.5rem)
            Positioned(
              top: size.height * 0.25 - dotY, // dot reverse → ngược chiều
              right: 40 - dotX,
              child: _DecorativeCircle(size: 16),
            ),

            // ── 3. Circle mid-right: absolute top-[50%] right-[-40px] w-48 h-48 ─
            // HTML: top: 50%, right: -40px
            Positioned(
              top: size.height * 0.50 + circleY,
              right: -40 + circleX,
              child: _DecorativeCircle(size: 192),
            ),

            // ── 4. Dot bottom-left: absolute bottom-[40%] left-20 w-3 h-3 ──
            // HTML: bottom: 40%, left: 80px (left-20 = 5rem)
            Positioned(
              bottom: size.height * 0.40 - dotY, // dot reverse
              left: 80 - dotX,
              child: _DecorativeCircle(size: 12),
            ),
          ],
        );
      },
    );
  }
}

/// Hình tròn trang trí — màu primary #F15A22, opacity 15%.
///
/// Dùng chung cho cả circle lớn và dot nhỏ, chỉ khác kích thước.
class _DecorativeCircle extends StatelessWidget {
  final double size;

  const _DecorativeCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Màu: primary #F15A22, opacity 15% — đồng bộ với HTML opacity-[0.15].
        color: const Color(0xFFF15A22).withValues(alpha: 0.15),
      ),
    );
  }
}
