import 'package:flutter/material.dart';

/// Horizontal scrollable stats strip — Questions, Exams, Attempts.
class StatsStrip extends StatelessWidget {
  final int totalQuestions;
  final int totalExams;
  final int totalAttempts;

  const StatsStrip({
    super.key,
    required this.totalQuestions,
    required this.totalExams,
    required this.totalAttempts,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _StatCard(
            icon: Icons.quiz,
            value: totalQuestions,
            label: 'Questions',
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.assignment,
            value: totalExams,
            label: 'Exams',
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.how_to_reg,
            value: totalAttempts,
            label: 'Attempts',
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF15A22).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFF15A22), size: 22),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: const TextStyle(
              color: Color(0xFF1D3557),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF485F84),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
