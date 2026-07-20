import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/enrollment_bloc.dart';
import '../bloc/enrollment_event.dart';
import '../bloc/enrollment_state.dart';
import '../data/enrollment_repository.dart';
import '../models/enrollment_model.dart';


class MyRegisteredCoursesScreen extends StatelessWidget {
  const MyRegisteredCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EnrollmentBloc(EnrollmentRepository())..add(LoadMyEnrollments()),
      child: const _MyRegisteredCoursesContent(),
    );
  }
}

class _MyRegisteredCoursesContent extends StatefulWidget {
  const _MyRegisteredCoursesContent();

  @override
  State<_MyRegisteredCoursesContent> createState() => _MyRegisteredCoursesContentState();
}

class _MyRegisteredCoursesContentState extends State<_MyRegisteredCoursesContent> {
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
          onPressed: () => context.go('/student/courses/catalog'),
        ),
        title: const Text(
          'My Registered Courses',
          style: TextStyle(
            color: AppTheme.navy,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/student/courses/catalog'),
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primary, size: 26),
            tooltip: 'Đăng ký môn mới',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<EnrollmentBloc, EnrollmentState>(
        listenWhen: (_, state) =>
            state is EnrollmentActionSuccess || state is EnrollmentActionFailure,
        listener: (context, state) {
          if (state is EnrollmentActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.success,
              ),
            );
            context.read<EnrollmentBloc>().add(LoadMyEnrollments());
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
            state is MyEnrollmentsLoaded ||
            state is EnrollmentLoadFailure,
        builder: (context, state) {
          if (state is EnrollmentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EnrollmentLoadFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
                    const SizedBox(height: 12),
                    Text(
                      'Lỗi: ${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.error),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.read<EnrollmentBloc>().add(LoadMyEnrollments()),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is MyEnrollmentsLoaded) {
            final enrollments = state.enrollments;
            final totalCredits = enrollments.length * 3;
            final confirmed = enrollments.length;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Top Summary Stats Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _summaryTile(
                            'Total Credits',
                            '$totalCredits',
                            AppTheme.primary,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.border,
                        ),
                        Expanded(
                          child: _summaryTile(
                            'Registered Courses',
                            '$confirmed',
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (enrollments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 48, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              'Bạn chưa đăng ký môn học nào.',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...enrollments.map((course) {
                      final cat = 'Core';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Tag & Status
                              Padding(
                                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildCategoryChip(cat),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF), // soft blue
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                      child: const Text(
                                        'Confirmed',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1D4ED8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Title
                              Padding(
                                padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course.courseCode,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.navy,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      course.courseNameOnly,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Info Details
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.person_outline_rounded, size: 15, color: Colors.grey),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'GV: BE Teacher',
                                          style: TextStyle(color: Colors.grey, fontSize: 13),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.menu_book_rounded, size: 15, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        const Text(
                                          '3 Credits',
                                          style: TextStyle(color: Colors.grey, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    const Row(
                                      children: [
                                        Icon(Icons.access_time_rounded, size: 15, color: Colors.grey),
                                        SizedBox(width: 6),
                                        Text(
                                          'Lịch: TBD • Phòng: TBD',
                                          style: TextStyle(color: Colors.grey, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Bottom Actions
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      height: 36,
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppTheme.error,
                                          side: const BorderSide(color: AppTheme.error, width: 1),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(horizontal: 14),
                                        ),
                                        onPressed: () => _showWithdrawModal(context, course),
                                        icon: const Icon(Icons.exit_to_app_rounded, size: 16),
                                        label: const Text(
                                          'Unenroll',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      // Sub-screen: navigation via AppBar back button
    );
  }

  Widget _buildCategoryChip(String category) {
    Color bg;
    Color text;
    switch (category.toUpperCase()) {
      case 'CORE':
        bg = const Color(0xFFEFF6FF);
        text = const Color(0xFF1D4ED8);
        break;
      case 'PROGRAMMING':
        bg = const Color(0xFFFDF2F8);
        text = const Color(0xFFBE185D);
        break;
      case 'SYSTEMS':
        bg = const Color(0xFFECFDF5);
        text = const Color(0xFF047857);
        break;
      case 'MATH':
        bg = const Color(0xFFFFF7ED);
        text = const Color(0xFFC2410C);
        break;
      case 'CAPSTONE':
        bg = const Color(0xFFF5F3FF);
        text = const Color(0xFF6D28D9);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        text = const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showWithdrawModal(BuildContext context, EnrollmentModel course) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            const Icon(
              Icons.warning_amber_rounded,
              size: 42,
              color: AppTheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Hủy đăng ký?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                children: [
                  const TextSpan(text: 'Bạn có chắc chắn muốn rút khỏi môn học '),
                  TextSpan(
                    text: "'${course.courseNameOnly}'",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navy),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textMuted,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<EnrollmentBloc>().add(UnenrollSubject(course.subjectId));
                    },
                    child: const Text(
                      'Xác nhận',
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

  Widget _summaryTile(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
