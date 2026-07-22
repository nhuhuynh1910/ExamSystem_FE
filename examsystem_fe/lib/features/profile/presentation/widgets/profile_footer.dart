import 'package:flutter/material.dart';

/// Footer pixel-perfect theo HTML:
/// - School icon + "FPT University" text (extrabold, 18px)
/// - Version text (12px, medium)
/// - Opacity 0.4
class ProfileFooter extends StatelessWidget {
  const ProfileFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.school,
                  size: 28,
                  color: Color(0xFF1D3557),
                ),
                SizedBox(width: 8),
                Text(
                  'FPT University',
                  style: TextStyle(
                    color: Color(0xFF1D3557),
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'FPT ExamHub v1.0.0',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
