import 'package:flutter/material.dart';

/// Widget tái sử dụng cho từng mục menu trong Profile.
///
/// Pixel-perfect theo HTML:
/// - height: 52px
/// - icon trong circle bg 32x32 (#FFF3EE)
/// - label: #1D3557, font-medium, 14px
/// - trailing: chevron_right hoặc custom (badge + chevron)
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showDivider;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: const Color(0xFFE5EEFF),
            highlightColor: const Color(0xFFE5EEFF),
            child: SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Icon circle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF3EE),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 18,
                        color: const Color(0xFFF15A22),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Label
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Color(0xFF1D3557),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // Trailing
                    trailing ??
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: Color(0xFF8E7067),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F5F9),
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
