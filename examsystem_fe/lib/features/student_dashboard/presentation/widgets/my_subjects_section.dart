import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../features/Enrollment/data/enrollment_repository.dart';
import '../../bloc/student_dashboard_bloc.dart';
import '../../bloc/student_dashboard_event.dart';
import '../../models/student_subject_model.dart';

/// Section "📖 My Subjects" — hiển thị danh sách môn học đã đăng ký dạng lướt ngang.
/// Nhận `searchQuery` dùng chung từ thanh tìm kiếm chung trên Student Dashboard.
class MySubjectsSection extends StatelessWidget {
  final List<StudentSubjectModel> subjects;
  final String searchQuery;

  const MySubjectsSection({
    super.key,
    required this.subjects,
    this.searchQuery = '',
  });

  void _openCourseCatalog(BuildContext context) {
    context.push(AppRouter.studentCatalog).then((_) {
      if (context.mounted) {
        context
            .read<StudentDashboardBloc>()
            .add(const StudentDashboardLoadRequested());
      }
    });
  }

  void _openRegisteredCourses(BuildContext context) {
    context.push(AppRouter.studentRegistered).then((_) {
      if (context.mounted) {
        context
            .read<StudentDashboardBloc>()
            .add(const StudentDashboardLoadRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter subjects by shared search query
    final filteredSubjects = subjects.where((subject) {
      if (searchQuery.isEmpty) return true;
      final query = searchQuery.toLowerCase();
      final nameMatches = subject.subjectName.toLowerCase().contains(query);
      final teacherMatches =
          subject.teacherName.toLowerCase().contains(query);
      return nameMatches || teacherMatches;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header Row: Title + "See All" / "+ Enroll" ────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    '📖 My Subjects',
                    style: TextStyle(
                      color: Color(0xFF1D3557),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subjects.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3EE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${subjects.length}',
                        style: const TextStyle(
                          color: Color(0xFFF15A22),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              Row(
                children: [
                  // Link See All / Môn đã ĐK
                  GestureDetector(
                    onTap: () => _openRegisteredCourses(context),
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: Color(0xFFF15A22),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nút "+ Enroll"
                  FilledButton.icon(
                    onPressed: () => _openCourseCatalog(context),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 14),
                    label: const Text(
                      'Enroll',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF15A22),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Horizontal Scrolling Cards (List Subject lướt ngang) ──────────────
        if (subjects.isEmpty)
          // Empty State khi chưa đăng ký môn nào
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF3EE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu_book_outlined,
                      size: 32,
                      color: Color(0xFFF15A22),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No subjects enrolled',
                    style: TextStyle(
                      color: Color(0xFF1D3557),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _openCourseCatalog(context),
                    icon: const Icon(Icons.library_add_rounded, size: 15),
                    label: const Text('Enroll Subjects Now'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF15A22),
                      side: const BorderSide(color: Color(0xFFF15A22)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (filteredSubjects.isEmpty)
          // Search Empty State
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: Text(
                  'No enrolled subjects matching "$searchQuery"',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          )
        else
          // Danh sách môn học lướt ngang
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < filteredSubjects.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    _HorizontalSubjectCard(
                      subject: filteredSubjects[i],
                      onTap: () => _openRegisteredCourses(context),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Card môn học thiết kế LƯỚT NGANG
class _HorizontalSubjectCard extends StatelessWidget {
  final StudentSubjectModel subject;
  final VoidCallback onTap;

  const _HorizontalSubjectCard({
    required this.subject,
    required this.onTap,
  });

  void _showUnenrollConfirmation(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    final bloc = context.read<StudentDashboardBloc>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            const Icon(
              Icons.warning_amber_rounded,
              size: 44,
              color: Color(0xFFBA1A1A),
            ),
            const SizedBox(height: 12),
            const Text(
              'Unenroll from Subject?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D3557),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to unenroll from "${subject.subjectName}"?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFBA1A1A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        await EnrollmentRepository()
                            .unenrollSubject(subject.subjectId);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Successfully unenrolled from "${subject.subjectName}"!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // Refresh Dashboard
                        bloc.add(const StudentDashboardLoadRequested());
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Unenroll failed: ${e.toString().replaceAll("Exception: ", "")}',
                            ),
                            backgroundColor: const Color(0xFFBA1A1A),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Confirm Unenroll',
                      style: TextStyle(fontWeight: FontWeight.bold),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 210,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subject name (Title) — max 2 lines
            Text(
              subject.subjectName,
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

            // Teacher Name Tag Pill (Orange tag)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF15A22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                subject.teacherName,
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

            // Status Tag Box ("Enrolled")
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF047857),
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Enrolled',
                    style: TextStyle(
                      color: Color(0xFF047857),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Bottom row: Student Count + Unenroll Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Student count
                Row(
                  children: [
                    Icon(
                      Icons.group_outlined,
                      color: Colors.grey.shade500,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${subject.studentCount}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Unenroll button
                GestureDetector(
                  onTap: () => _showUnenrollConfirmation(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFFCA5A5),
                        width: 0.8,
                      ),
                    ),
                    child: const Text(
                      'Unenroll',
                      style: TextStyle(
                        color: Color(0xFFBA1A1A),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
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
