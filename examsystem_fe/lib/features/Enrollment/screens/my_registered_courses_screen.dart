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
      appBar: AppBar(
        title: const Text('Môn đã đăng ký'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.navy,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.go('/student/courses/catalog'),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
      body: BlocConsumer<EnrollmentBloc, EnrollmentState>(
        listenWhen: (_, state) =>
            state is EnrollmentActionSuccess || state is EnrollmentActionFailure,
        listener: (context, state) {
          if (state is EnrollmentActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Tải lại sau khi hủy đăng ký thành công
            context.read<EnrollmentBloc>().add(LoadMyEnrollments());
          } else if (state is EnrollmentActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
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
            final totalCredits = enrollments.length * 3; // Giả sử mỗi môn 3 tín chỉ
            final confirmed = enrollments.length;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _summaryTile(
                            'Tổng tín chỉ',
                            '$totalCredits',
                            AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _summaryTile(
                            'Đã xác nhận',
                            '$confirmed',
                            AppTheme.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (enrollments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'Bạn chưa đăng ký môn học nào.',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      ),
                    )
                  else
                    ...enrollments.map((course) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${course.subjectId} • ${course.subjectName}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.navy,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: const Text(
                                        'Confirmed',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'GV: BE teacher • 3 tín chỉ',
                                  style: TextStyle(color: AppTheme.textMuted),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Lịch: From API • Phòng: TBD',
                                  style: TextStyle(color: AppTheme.textMuted),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _showWithdrawModal(context, course),
                                        icon: const Icon(
                                          Icons.exit_to_app_rounded,
                                          size: 18,
                                        ),
                                        label: const Text('Unenroll'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
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
              color: AppTheme.warning,
            ),
            const SizedBox(height: 12),
            Text(
              'Hủy đăng ký ${course.subjectName}?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bạn có chắc muốn rút khỏi môn này?',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<EnrollmentBloc>().add(UnenrollSubject(course.subjectId));
                    },
                    child: const Text('Xác nhận'),
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
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
      ],
    );
  }
}
