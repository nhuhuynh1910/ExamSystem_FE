import 'package:flutter/material.dart';

import '../../models/teacher_exam_model.dart';

/// Card đề thi — hiển thị trong danh sách "My Exams".
class ExamCard extends StatelessWidget {
  final TeacherExamModel exam;

  const ExamCard({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2BFB4).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Icon + Title + Status badge
          Row(
            children: [
              // Icon môn học
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF15A22).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.article,
                  color: Color(0xFFF15A22),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Title + Subject tag
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.examName,
                      style: const TextStyle(
                        color: Color(0xFF1D3557),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF15A22).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        exam.subjectName ?? 'Unknown Subject',
                        style: const TextStyle(
                          color: Color(0xFFF15A22),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              _StatusBadge(status: exam.status),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Metadata (questions + attempts)
          Row(
            children: [
              const Icon(Icons.list_alt, size: 16, color: Color(0xFF485F84)),
              const SizedBox(width: 4),
              Text(
                '${exam.maxAttempts} max attempts',
                style: const TextStyle(
                  color: Color(0xFF485F84),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 12),
              const Text('•', style: TextStyle(color: Color(0xFF485F84))),
              const SizedBox(width: 12),
              const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF485F84)),
              const SizedBox(width: 4),
              Text(
                '${exam.durationMinutes} min',
                style: const TextStyle(
                  color: Color(0xFF485F84),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color text) = switch (status.toLowerCase()) {
      'published' => (const Color(0xFFDCFCE7), const Color(0xFF15803D)),
      'draft'     => (const Color(0xFFF3F4F6), const Color(0xFF6B7280)),
      'closed'    => (const Color(0xFFFEE2E2), const Color(0xFFDC2626)),
      _           => (const Color(0xFFF3F4F6), const Color(0xFF6B7280)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
