import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../exam/screens/exam_result_screen.dart';
import '../models/student_result_model.dart';

class ResultCardWidget extends StatelessWidget {
  final StudentResultModel result;

  const ResultCardWidget({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = result.scorePercentage.round();
    final isPassed = result.isPassed;
    final dateStr = result.submitTime != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(result.submitTime!)
        : 'Vừa xong';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (result.attemptId > 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExamResultScreen(
                    attemptId: result.attemptId,
                    submitResponse: result.toSubmitResponse(),
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Vòng tròn phần trăm điểm (% score)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isPassed
                          ? const Color(0xFF10B981) // Green
                          : const Color(0xFFEF4444), // Red
                      width: 3,
                    ),
                    color: isPassed
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF2F2),
                  ),
                  child: Center(
                    child: Text(
                      '$percentage%',
                      style: TextStyle(
                        color: isPassed
                            ? const Color(0xFF047857)
                            : const Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Thông tin bài thi & môn học
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.examName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.navy,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (result.subjectName != null &&
                          result.subjectName!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          result.subjectName!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF15A22),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            result.totalQuestions > 0
                                ? '${result.correctAnswers} / ${result.totalQuestions} câu đúng (${result.score}/${result.totalScore}đ)'
                                : 'Điểm: ${result.score} / ${result.totalScore}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Tag Đạt / Chưa đạt + Icon xem chi tiết
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPassed
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPassed
                              ? const Color(0xFFA7F3D0)
                              : const Color(0xFFFECACA),
                        ),
                      ),
                      child: Text(
                        isPassed ? 'Đạt' : 'Chưa đạt',
                        style: TextStyle(
                          color: isPassed
                              ? const Color(0xFF047857)
                              : const Color(0xFFDC2626),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
