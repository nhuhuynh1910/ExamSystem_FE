import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../Enrollment/data/enrollment_repository.dart';
import '../../../Enrollment/models/subject_model.dart';
import '../../bloc/student_dashboard_bloc.dart';
import '../../bloc/student_dashboard_event.dart';
import '../../models/student_subject_model.dart';

/// Section "📚 Available Subjects to Enroll" — danh sách môn học mở trong hệ thống.
/// Thiết kế thẻ lướt ngang tinh gọn & cân đối tuyệt đối.
class AvailableSubjectsSection extends StatelessWidget {
  final List<SubjectModel> availableSubjects;
  final List<StudentSubjectModel> enrolledSubjects;
  final String searchQuery;

  const AvailableSubjectsSection({
    super.key,
    required this.availableSubjects,
    required this.enrolledSubjects,
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

  @override
  Widget build(BuildContext context) {
    // Tập hợp danh sách ID môn đã đăng ký
    final enrolledSubjectIds =
        enrolledSubjects.map((s) => s.subjectId).toSet();

    // Filter available subjects by shared search query
    final filteredCatalog = availableSubjects.where((subject) {
      if (searchQuery.isEmpty) return true;
      final query = searchQuery.toLowerCase().trim();
      final nameMatches = subject.subjectName.toLowerCase().contains(query);
      final nameOnlyMatches =
          subject.courseNameOnly.toLowerCase().contains(query);
      final codeMatches = subject.courseCode.toLowerCase().contains(query);
      return nameMatches || nameOnlyMatches || codeMatches;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header: Title + "Explore Catalog" ─────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📚 Available Subjects to Enroll',
                style: TextStyle(
                  color: Color(0xFF1D3557),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => _openCourseCatalog(context),
                child: const Text(
                  'Explore Catalog',
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

        // ── Horizontal List Cards ──────────────────────────────────────────────
        if (availableSubjects.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: Text(
                  'No available courses in catalog right now',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          )
        else if (filteredCatalog.isEmpty)
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
                  'No catalog subjects matching "$searchQuery"',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (int i = 0; i < filteredCatalog.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  _CatalogSubjectCard(
                    subject: filteredCatalog[i],
                    isEnrolled: enrolledSubjectIds
                        .contains(filteredCatalog[i].subjectId),
                    onCatalogTap: () => _openCourseCatalog(context),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _CatalogSubjectCard extends StatefulWidget {
  final SubjectModel subject;
  final bool isEnrolled;
  final VoidCallback onCatalogTap;

  const _CatalogSubjectCard({
    required this.subject,
    required this.isEnrolled,
    required this.onCatalogTap,
  });

  @override
  State<_CatalogSubjectCard> createState() => _CatalogSubjectCardState();
}

class _CatalogSubjectCardState extends State<_CatalogSubjectCard> {
  bool _isSubmitting = false;

  Future<void> _enrollSubject(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final bloc = context.read<StudentDashboardBloc>();

    setState(() {
      _isSubmitting = true;
    });

    try {
      await EnrollmentRepository().enrollSubject(widget.subject.subjectId);
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Đã đăng ký thành công môn "${widget.subject.subjectName}"!',
            ),
            backgroundColor: const Color(0xFF047857),
          ),
        );
        // Refresh Dashboard
        bloc.add(const StudentDashboardLoadRequested());
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Đăng ký thất bại: ${e.toString().replaceAll("Exception: ", "")}',
            ),
            backgroundColor: const Color(0xFFBA1A1A),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tên môn học hiển thị trực tiếp (ví dụ: Programming Mobile)
    final displayName = widget.subject.subjectName.isNotEmpty
        ? widget.subject.subjectName
        : widget.subject.courseNameOnly;

    return GestureDetector(
      onTap: widget.onCatalogTap,
      child: Container(
        width: 215,
        height: 125, // Height chuẩn cố định giúp các thẻ căn hàng bằng phẳng
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Row Tiêu đề + Icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3EE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 16,
                    color: Color(0xFFF15A22),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      color: Color(0xFF1D3557),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Action / Status Button ở đáy thẻ
            if (widget.isEnrolled)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: Color(0xFF047857),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Enrolled',
                      style: TextStyle(
                        color: Color(0xFF047857),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 32,
                child: FilledButton.icon(
                  onPressed:
                      _isSubmitting ? null : () => _enrollSubject(context),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add_circle_outline_rounded, size: 14),
                  label: Text(
                    _isSubmitting ? 'Enrolling...' : 'Enroll Subject',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF15A22),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
