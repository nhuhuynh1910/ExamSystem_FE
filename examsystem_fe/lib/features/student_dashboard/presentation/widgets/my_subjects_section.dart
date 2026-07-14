import 'package:flutter/material.dart';

import '../../models/student_subject_model.dart';

/// Section "📖 My Subjects" — danh sách dọc các môn học đã đăng ký.
///
/// Mỗi card có viền trái cam (border-l-4 border-fpt-orange),
/// hiển thị tên môn, tên giảng viên, badge số SV, chevron_right.
class MySubjectsSection extends StatelessWidget {
  final List<StudentSubjectModel> subjects;

  const MySubjectsSection({
    super.key,
    required this.subjects,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            '📖 My Subjects',
            style: TextStyle(
              color: Color(0xFF1D3557),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Subject cards
          if (subjects.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 40,
                      color: Color(0xFF485F84),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No subjects enrolled',
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
            ...subjects.map((subject) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SubjectCard(subject: subject),
                )),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final StudentSubjectModel subject;

  const _SubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to subject detail
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
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
        child: Row(
          children: [
            // Left: Subject name + teacher name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.subjectName,
                    style: const TextStyle(
                      color: Color(0xFF1D3557),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subject.teacherName,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Right: Student count badge + chevron
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Student count badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group, size: 14, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        '${subject.studentCount}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
