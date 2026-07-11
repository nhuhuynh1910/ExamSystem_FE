import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';
import '../data/teacher_repository.dart';

class TeacherAssignedCoursesScreen extends StatelessWidget {
  const TeacherAssignedCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TeacherBloc(TeacherRepository())..add(LoadAssignedCourses()),
      child: const _TeacherAssignedCoursesContent(),
    );
  }
}

class _TeacherAssignedCoursesContent extends StatefulWidget {
  const _TeacherAssignedCoursesContent();

  @override
  State<_TeacherAssignedCoursesContent> createState() =>
      _TeacherAssignedCoursesContentState();
}

class _TeacherAssignedCoursesContentState
    extends State<_TeacherAssignedCoursesContent> {
  String _selectedSemester = 'Summer 2025';

  @override
  Widget build(BuildContext context) {
    final semesters = ['Summer 2025', 'Fall 2024'];

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Môn được phân công'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.navy,
        elevation: 0,
      ),
      body: BlocBuilder<TeacherBloc, TeacherState>(
        builder: (context, state) {
          if (state is TeacherLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TeacherFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
                    const SizedBox(height: 12),
                    Text(
                      'Lỗi: ${state.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.error),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.read<TeacherBloc>().add(LoadAssignedCourses()),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is AssignedCoursesLoaded) {
            final filtered = state.courses
                .where((c) => c.semester == _selectedSemester)
                .toList();
            final activeCourses = filtered.where((c) => c.status == 'Active').length;
            final totalStudents = filtered.fold(0, (sum, c) => sum + c.students);

            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Học kỳ',
                        style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedSemester,
                        items: semesters
                            .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedSemester = value ?? _selectedSemester),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.lightBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _statPill(
                              Icons.school_rounded,
                              '$activeCourses active',
                              AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _statPill(
                              Icons.people_rounded,
                              '$totalStudents sinh viên',
                              AppTheme.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'Không có môn học nào trong học kỳ này.',
                            style: TextStyle(color: AppTheme.textMuted),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, index) {
                            final course = filtered[index];
                            return Container(
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
                                          '${course.code} • ${course.name}',
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
                                        child: Text(
                                          course.status,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${course.students} sinh viên • ${course.room}',
                                    style: const TextStyle(color: AppTheme.textMuted),
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: course.progress,
                                    backgroundColor: AppTheme.lightBg,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.success),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Lớp tiếp theo: ${course.nextClass}',
                                    style: const TextStyle(color: AppTheme.textMuted),
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: FilledButton.icon(
                                      onPressed: () => context.push(
                                        '/teacher/courses/${course.code}/roster',
                                        extra: course.name,
                                      ),
                                      icon: const Icon(Icons.groups_rounded),
                                      label: const Text('Xem roster'),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _statPill(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
