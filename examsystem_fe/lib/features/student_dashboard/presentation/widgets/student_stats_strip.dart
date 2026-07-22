import 'package:flutter/material.dart';

/// Student Stats Strip — 3 thẻ thống kê lướt ngang.
///
/// Thiết kế theo prototype student_dashboard.txt:
///   - Chiều rộng cố định 110px, icon trên nền orange-50
///   - Shadow orange-glow (0px 4px 12px rgba(241,90,34,0.15))
///   - Border border-gray-100
///   - gap-2 giữa các elements trong card
class StudentStatsStrip extends StatelessWidget {
  final int enrolledCount;
  final int examsTakenCount;
  final String bestScore;

  const StudentStatsStrip({
    super.key,
    required this.enrolledCount,
    required this.examsTakenCount,
    required this.bestScore,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatCard(
              icon: Icons.menu_book_rounded,
              value: '$enrolledCount',
              label: 'Enrolled',
            ),
            const SizedBox(width: 12),
            _StatCard(
              icon: Icons.check_circle_rounded,
              value: '$examsTakenCount',
              label: 'Exams Taken',
            ),
            const SizedBox(width: 12),
            _StatCard(
              icon: Icons.emoji_events_rounded,
              value: bestScore,
              label: 'Best Score',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF15A22).withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon container (orange-50 background, rounded-lg) — w-8 h-8
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED), // orange-50
              borderRadius: BorderRadius.circular(8), // rounded-lg
            ),
            child: Center(
              child: Icon(icon, color: const Color(0xFFF15A22), size: 20),
            ),
          ),
          const SizedBox(height: 8), // gap-2
          // Value — text-fpt-navy font-bold text-2xl
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1D3557), // fpt-navy
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          // Label — text-gray-500 text-xs font-medium
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
