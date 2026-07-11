import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/subject_bloc.dart';
import '../bloc/subject_event.dart';
import '../bloc/subject_state.dart';
import '../data/subject_repository.dart';
import '../models/subject_model.dart';

class AdminCourseManagementScreen extends StatelessWidget {
  const AdminCourseManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubjectBloc(SubjectRepository())..add(LoadSubjects()),
      child: const _AdminCourseManagementContent(),
    );
  }
}

class _AdminCourseManagementContent extends StatefulWidget {
  const _AdminCourseManagementContent();

  @override
  State<_AdminCourseManagementContent> createState() =>
      _AdminCourseManagementContentState();
}

class _AdminCourseManagementContentState
    extends State<_AdminCourseManagementContent> {
  String _selectedFilter = 'All';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Active', 'Pending'];

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Quản lý môn học'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.navy,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              // Sau khi quay lại từ màn tạo mới, tải lại danh sách môn học
              await context.push('/admin/courses/create');
              if (mounted) {
                context.read<SubjectBloc>().add(LoadSubjects());
              }
            },
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
      body: BlocConsumer<SubjectBloc, SubjectState>(
        listenWhen: (_, state) => state is SubjectActionSuccess,
        listener: (context, state) {
          if (state is SubjectActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.read<SubjectBloc>().add(LoadSubjects());
          }
        },
        builder: (context, state) {
          if (state is SubjectLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SubjectFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${state.errorMessage}', style: const TextStyle(color: AppTheme.error)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<SubjectBloc>().add(LoadSubjects()),
                    child: const Text('Tải lại'),
                  )
                ],
              ),
            );
          }

          if (state is SubjectsLoaded) {
            final q = _searchController.text.toLowerCase();
            final filtered = state.subjects.where((c) {
              final statusStr = c.isActive ? 'Active' : 'Pending';
              final matchesFilter =
                  _selectedFilter == 'All' || statusStr == _selectedFilter;
              final matchesSearch = q.isEmpty ||
                  c.subjectId.toString().contains(q) ||
                  c.subjectName.toLowerCase().contains(q);
              return matchesFilter && matchesSearch;
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm môn học...',
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    children: filters.map((filter) {
                      final selected = filter == _selectedFilter;
                      return ChoiceChip(
                        label: Text(filter),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedFilter = filter),
                        selectedColor: AppTheme.primary.withOpacity(0.12),
                        labelStyle: TextStyle(
                          color: selected ? AppTheme.primary : AppTheme.textMuted,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('Không tìm thấy môn học nào.'))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (ctx, index) {
                            final course = filtered[index];
                            return _CourseManagementCard(
                              course: course,
                              onDelete: () => _showDeleteDialog(context, course),
                              onEdit: () async {
                                await context.push('/admin/courses/${course.subjectId}');
                                if (context.mounted) {
                                  context.read<SubjectBloc>().add(LoadSubjects());
                                }
                              },
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

  void _showDeleteDialog(BuildContext context, SubjectModel course) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa môn học'),
        content: Text('Bạn có chắc muốn xóa ${course.subjectName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SubjectBloc>().add(DeleteSubjectEvent(course.subjectId));
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class _CourseManagementCard extends StatelessWidget {
  final SubjectModel course;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _CourseManagementCard({
    required this.course,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = course.isActive;
    final statusColor = isActive ? AppTheme.success : AppTheme.warning;
    final statusBg = isActive
        ? AppTheme.success.withOpacity(0.12)
        : AppTheme.warning.withOpacity(0.14);

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
                  color: statusBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isActive ? 'Active' : 'Pending',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (course.description != null && course.description!.isNotEmpty) ...[
            Text(
              course.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_note_rounded, size: 18),
                label: const Text('Sửa'),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    context.push('/admin/courses/${course.subjectId}/students'),
                icon: const Icon(Icons.people_alt_rounded, size: 18),
                label: const Text('Sinh viên'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push(
                  '/admin/courses/${course.subjectId}/assign-teacher',
                ),
                icon: const Icon(Icons.person_add_alt_rounded, size: 18),
                label: const Text('Giáo viên'),
              ),
              OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Xóa'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
