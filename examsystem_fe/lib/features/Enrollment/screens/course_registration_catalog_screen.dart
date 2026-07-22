import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../common/skeleton_loader.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/enrollment_bloc.dart';
import '../bloc/enrollment_event.dart';
import '../bloc/enrollment_state.dart';
import '../data/enrollment_repository.dart';
import '../models/enrollment_model.dart';
import '../models/subject_model.dart';

/// Màn hình Catalog — Sinh viên duyệt, xem chi tiết, đăng ký và hủy đăng ký môn học.
class CourseRegistrationCatalogScreen extends StatelessWidget {
  const CourseRegistrationCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EnrollmentBloc(EnrollmentRepository())..add(LoadCatalog()),
      child: const _CatalogView(),
    );
  }
}

class _CatalogView extends StatefulWidget {
  const _CatalogView();

  @override
  State<_CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<_CatalogView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      // ── App Bar ──────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.navy),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/student/home');
            }
          },
        ),
        title: const Row(
          children: [
            Icon(Icons.library_books_rounded, color: AppTheme.primary),
            SizedBox(width: 8),
            Text(
              'Course Catalog',
              style: TextStyle(
                color: AppTheme.navy,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/student/courses/registered'),
            icon: const Icon(Icons.fact_check_rounded, color: AppTheme.primary, size: 26),
            tooltip: 'Enrolled Subjects',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<EnrollmentBloc, EnrollmentState>(
        listenWhen: (_, state) =>
            state is EnrollmentActionSuccess ||
            state is EnrollmentActionFailure,
        listener: (context, state) {
          if (state is EnrollmentActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.success,
              ),
            );
            context.read<EnrollmentBloc>().add(LoadCatalog());
          } else if (state is EnrollmentActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        buildWhen: (_, state) =>
            state is EnrollmentLoading ||
            state is CatalogLoaded ||
            state is EnrollmentLoadFailure,
        builder: (context, state) {
          if (state is EnrollmentLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: SkeletonListLoader(count: 4, cardHeight: 110),
            );
          }

          if (state is EnrollmentLoadFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 48, color: AppTheme.error),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load data: ${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.error),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () =>
                          context.read<EnrollmentBloc>().add(LoadCatalog()),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is CatalogLoaded) {
            return _buildCatalogList(
                context, state.subjects, state.enrolledSubjectsList);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCatalogList(
    BuildContext context,
    List<SubjectModel> subjects,
    List<EnrollmentModel> enrolledSubjects,
  ) {
    final enrolledSubjectIds =
        enrolledSubjects.map((e) => e.subjectId).toSet();

    // Standardized robust search filter
    final q = _searchController.text.toLowerCase().trim();
    final filtered = subjects.where((s) {
      if (q.isEmpty) return true;
      final codeMatch = s.courseCode.toLowerCase().contains(q);
      final nameMatch = s.subjectName.toLowerCase().contains(q);
      final nameOnlyMatch = s.courseNameOnly.toLowerCase().contains(q);
      final descMatch = s.cleanDescription.toLowerCase().contains(q);
      final idMatch = s.subjectId.toString() == q;

      return codeMatch || nameMatch || nameOnlyMatch || descMatch || idMatch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Banner Subtitle
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available Courses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Explore and enroll in active courses for this semester',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search course code or name...',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.grey, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),

        // Course List
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'No subjects found.',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (_, index) {
                    final subject = filtered[index];
                    final isEnrolled =
                        enrolledSubjectIds.contains(subject.subjectId);

                    return _CatalogCourseCard(
                      subject: subject,
                      isEnrolled: isEnrolled,
                      onEnroll: () {
                        context
                            .read<EnrollmentBloc>()
                            .add(EnrollSubject(subject.subjectId));
                      },
                      onUnenroll: () {
                        context
                            .read<EnrollmentBloc>()
                            .add(UnenrollSubject(subject.subjectId));
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CatalogCourseCard extends StatelessWidget {
  final SubjectModel subject;
  final bool isEnrolled;
  final VoidCallback onEnroll;
  final VoidCallback onUnenroll;

  const _CatalogCourseCard({
    required this.subject,
    required this.isEnrolled,
    required this.onEnroll,
    required this.onUnenroll,
  });

  void _showSubjectDetailsModal(BuildContext context) {
    final displayName = subject.subjectName.isNotEmpty
        ? subject.subjectName
        : subject.courseNameOnly;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3EE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppTheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.navy,
                        ),
                      ),
                      if (subject.courseCode.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Code: ${subject.courseCode}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Info Pills Row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (subject.courseCategory.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Type: ${subject.courseCategory.toUpperCase()}',
                      style: const TextStyle(
                        color: Color(0xFF1D4ED8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${subject.courseCredits} Credits',
                    style: const TextStyle(
                      color: Color(0xFFC2410C),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isEnrolled
                        ? const Color(0xFFECFDF5)
                        : (subject.isActive
                            ? const Color(0xFFEFF6FF)
                            : const Color(0xFFFEF2F2)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isEnrolled
                        ? 'Enrolled'
                        : (subject.isActive
                            ? 'Active'
                            : 'Inactive'),
                    style: TextStyle(
                      color: isEnrolled
                          ? const Color(0xFF047857)
                          : (subject.isActive ? Colors.blue : Colors.red),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Description Heading & Body
            const Text(
              'Course Details:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                subject.cleanDescription.isNotEmpty
                    ? subject.cleanDescription
                    : 'No detailed description available for this subject.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade800,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Modal Action Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: isEnrolled
                  ? OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side:
                            const BorderSide(color: AppTheme.error, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        onUnenroll();
                      },
                      icon: const Icon(Icons.exit_to_app_rounded, size: 18),
                      label: const Text(
                        'Unenroll from this Subject',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: subject.isActive
                          ? () {
                              Navigator.pop(ctx);
                              onEnroll();
                            }
                          : null,
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          size: 18),
                      label: const Text(
                        'Enroll in this Subject',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = subject.subjectName.isNotEmpty
        ? subject.subjectName
        : subject.courseNameOnly;

    return GestureDetector(
      onTap: () => _showSubjectDetailsModal(context),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title + Status Pill
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.navy,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isEnrolled
                        ? const Color(0xFFECFDF5)
                        : (subject.isActive
                            ? const Color(0xFFEFF6FF)
                            : const Color(0xFFFEF2F2)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isEnrolled
                        ? 'Enrolled'
                        : (subject.isActive ? 'Active' : 'Inactive'),
                    style: TextStyle(
                      color: isEnrolled
                          ? const Color(0xFF047857)
                          : (subject.isActive ? Colors.blue : Colors.red),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // Description (if present)
            if (subject.cleanDescription.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                subject.cleanDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],

            const SizedBox(height: 14),

            // Bottom Row: Action Button aligned on the right
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isEnrolled)
                  SizedBox(
                    height: 36,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: const BorderSide(
                            color: AppTheme.error, width: 1.2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: onUnenroll,
                      icon: const Icon(Icons.exit_to_app_rounded, size: 16),
                      label: const Text(
                        'Unenroll',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 36,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: subject.isActive ? onEnroll : null,
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          size: 16),
                      label: const Text(
                        'Enroll',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
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
