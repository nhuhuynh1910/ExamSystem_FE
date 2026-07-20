import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/subject_bloc.dart';
import '../bloc/subject_event.dart';
import '../bloc/subject_state.dart';
import '../data/subject_repository.dart';
import '../models/teacher_in_subject_model.dart';
import '../models/teacher_user_model.dart';

class AssignTeacherScreen extends StatelessWidget {
  final String courseCode;
  final String courseName;

  const AssignTeacherScreen({
    super.key,
    this.courseCode = '1',
    this.courseName = 'Unknown Course',
  });

  @override
  Widget build(BuildContext context) {
    final subjectId = int.tryParse(courseCode) ?? 0;
    return BlocProvider(
      create: (_) => SubjectBloc(SubjectRepository())
        ..add(LoadAllTeachers(subjectId)),
      child: _AssignTeacherContent(
        subjectId: subjectId,
        courseName: courseName,
      ),
    );
  }
}

class _AssignTeacherContent extends StatefulWidget {
  final int subjectId;
  final String courseName;

  const _AssignTeacherContent({
    required this.subjectId,
    required this.courseName,
  });

  @override
  State<_AssignTeacherContent> createState() => _AssignTeacherContentState();
}

class _AssignTeacherContentState extends State<_AssignTeacherContent> {
  final _searchController = TextEditingController();
  int? _selectedTeacherId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text('Gán giáo viên — ${widget.courseName}'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.navy,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
      body: BlocConsumer<SubjectBloc, SubjectState>(
        listenWhen: (_, state) =>
            state is SubjectTeacherActionSuccess || state is SubjectFailure,
        listener: (context, state) {
          if (state is SubjectTeacherActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            setState(() => _selectedTeacherId = null);
            // Refresh lại danh sách GV sau khi gán/gỡ thành công
            context.read<SubjectBloc>().add(LoadAllTeachers(widget.subjectId));
          } else if (state is SubjectFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${state.errorMessage}')),
            );
          }
        },
        buildWhen: (_, state) =>
            state is SubjectLoading ||
            state is AllTeachersLoaded ||
            state is SubjectFailure,
        builder: (context, state) {
          if (state is SubjectLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SubjectFailure) {
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
                      state.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.error),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context
                          .read<SubjectBloc>()
                          .add(LoadAllTeachers(widget.subjectId)),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is AllTeachersLoaded) {
            return _buildContent(
              context,
              allTeachers: state.allTeachers,
              assignedTeachers: state.assignedTeachers,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required List<TeacherUserModel> allTeachers,
    required List<TeacherInSubjectModel> assignedTeachers,
  }) {
    final assignedIds =
        assignedTeachers.where((t) => t.isActive).map((t) => t.teacherId).toSet();

    final q = _searchController.text.toLowerCase();
    final filtered = allTeachers.where((t) {
      return q.isEmpty ||
          t.fullName.toLowerCase().contains(q) ||
          t.email.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        // Danh sách GV đang được gán
        if (assignedTeachers.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppTheme.success.withValues(alpha: 0.20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Giáo viên đang phụ trách',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(height: 8),
                ...assignedTeachers
                    .where((t) => t.isActive)
                    .map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.person_rounded,
                                size: 16, color: AppTheme.success),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${t.fullName} (${t.email})',
                                style: const TextStyle(
                                    color: AppTheme.navy, fontSize: 14),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _confirmUnassign(context, t),
                              child: const Icon(Icons.remove_circle_outline,
                                  size: 20, color: AppTheme.error),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm giáo viên...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),

        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'Không tìm thấy giáo viên nào.',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final teacher = filtered[index];
                    final isAssigned = assignedIds.contains(teacher.userId);
                    final isSelected = _selectedTeacherId == teacher.userId;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : isAssigned
                                  ? AppTheme.success
                                  : AppTheme.border,
                          width: isSelected || isAssigned ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppTheme.primary
                              .withValues(alpha: 0.10),
                          child: const Icon(Icons.person_rounded,
                              color: AppTheme.primary, size: 20),
                        ),
                        title: Text(
                          teacher.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.navy,
                          ),
                        ),
                        subtitle: Text(
                          teacher.email,
                          style:
                              const TextStyle(color: AppTheme.textMuted),
                        ),
                        trailing: isAssigned
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.success
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'Đã gán',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.success,
                                  ),
                                ),
                              )
                            : Radio<int>(
                                value: teacher.userId,
                                groupValue: _selectedTeacherId,
                                onChanged: (v) =>
                                    setState(() => _selectedTeacherId = v),
                              ),
                        onTap: isAssigned
                            ? null
                            : () => setState(
                                () => _selectedTeacherId = teacher.userId),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _confirmUnassign(BuildContext context, TeacherInSubjectModel teacher) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gỡ giáo viên'),
        content: Text(
            'Bạn có chắc muốn gỡ ${teacher.fullName} khỏi môn học này?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy')),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SubjectBloc>().add(UnassignTeacher(
                    subjectId: widget.subjectId,
                    teacherId: teacher.teacherId,
                  ));
            },
            child: const Text('Gỡ'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        color: Colors.white,
        child: FilledButton.icon(
          onPressed: _selectedTeacherId == null
              ? null
              : () => context.read<SubjectBloc>().add(AssignTeacher(
                    subjectId: widget.subjectId,
                    teacherId: _selectedTeacherId!,
                  )),
          icon: const Icon(Icons.person_add_rounded),
          label: const Text('Gán giáo viên đã chọn'),
        ),
      ),
    );
  }
}
