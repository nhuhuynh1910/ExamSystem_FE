import 'package:flutter/material.dart';

import '../../../teacher_dashboard/models/teacher_exam_model.dart';

/// Section "📅 Upcoming Exams" — danh sách đề thi sắp tới lướt ngang.
///
/// Mỗi card (w=200px) có viền trái cam (border-l-4 border-fpt-orange), shadow,
/// hiển thị tên đề, tag môn học, thời gian bắt đầu và duration.
class UpcomingExamsSection extends StatelessWidget {
  final List<TeacherExamModel> exams;

  const UpcomingExamsSection({
    super.key,
    required this.exams,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Title + "See All"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📅 Upcoming Exams',
                style: TextStyle(
                  color: Color(0xFF1D3557),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to full exam list
                },
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: Color(0xFFF15A22),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal scrolling cards
        if (exams.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.event_available,
                    size: 40,
                    color: Color(0xFF485F84),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No upcoming exams',
                    style: TextStyle(
                      color: Color(0xFF485F84),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // Dùng IntrinsicHeight: các card tự cao theo nội dung dài nhất
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < exams.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    _UpcomingExamCard(exam: exams[i]),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _UpcomingExamCard extends StatelessWidget {
  final TeacherExamModel exam;

  const _UpcomingExamCard({required this.exam});

  /// Tính "Starts in X days" hoặc "In progress" / "Ended".
  String _getTimeLabel() {
    final now = DateTime.now();
    final diff = exam.startTime.difference(now);

    if (diff.isNegative) {
      if (exam.endTime.isAfter(now)) return 'In progress';
      return 'Ended';
    }

    final days = diff.inDays;
    if (days == 0) {
      final hours = diff.inHours;
      if (hours == 0) return 'Starts soon';
      return 'Starts in ${hours}h';
    }
    if (days == 1) return 'Starts tomorrow';
    return 'Starts in $days days';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to exam detail / check-access flow
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: const Border(
            left: BorderSide(color: Color(0xFFF15A22), width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        // Dùng Column không có Spacer — tự co theo nội dung
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Exam name
            Text(
              exam.examName,
              style: const TextStyle(
                color: Color(0xFF1D3557),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Subject tag pill
            if (exam.subjectName != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF15A22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  exam.subjectName!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 8),

            // "Starts in X days" container — bg-[#FFF3EE] p-2 rounded-lg
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3EE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.schedule,
                    color: Color(0xFFF15A22),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _getTimeLabel(),
                      style: const TextStyle(
                        color: Color(0xFFF15A22),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Duration — flex items-center gap-1 text-gray-500
            Row(
              children: [
                Icon(Icons.timer_outlined,
                    color: Colors.grey.shade500, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${exam.durationMinutes} min',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
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
