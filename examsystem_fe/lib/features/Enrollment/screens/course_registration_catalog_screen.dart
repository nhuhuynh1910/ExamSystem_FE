import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../bloc/enrollment_bloc.dart';
import '../bloc/enrollment_event.dart';
import '../bloc/enrollment_state.dart';
import '../data/enrollment_repository.dart';
import '../models/subject_model.dart';

/// Màn hình Catalog — Sinh viên duyệt và đăng ký môn học.
///
/// Kiến trúc BLoC:
///   Screen dispatch Events → EnrollmentBloc xử lý → emit States → UI rebuild
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
  String _selectedDept = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final depts = [
      'All',
      'Software Engineering',
      'Artificial Intelligence',
      'Information Technology',
    ];

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Catalog môn học'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.navy,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.go('/student/courses/registered'),
            icon: const Icon(Icons.fact_check_rounded),
          ),
        ],
      ),
      body: BlocConsumer<EnrollmentBloc, EnrollmentState>(
        // Listener: xử lý action results (show SnackBar + refresh data)
        listenWhen: (_, state) =>
            state is EnrollmentActionSuccess ||
            state is EnrollmentActionFailure,
        listener: (context, state) {
          if (state is EnrollmentActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Refresh catalog sau khi enroll/unenroll thành công
            context.read<EnrollmentBloc>().add(LoadCatalog());
          } else if (state is EnrollmentActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        // Builder: rebuild UI theo data states
        buildWhen: (_, state) =>
            state is EnrollmentLoading ||
            state is CatalogLoaded ||
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
                    const Icon(Icons.error_outline_rounded,
                        size: 48, color: AppTheme.error),
                    const SizedBox(height: 12),
                    Text(
                      'Lỗi tải dữ liệu: ${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.error),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () =>
                          context.read<EnrollmentBloc>().add(LoadCatalog()),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is CatalogLoaded) {
            return _buildCatalogList(context, state.subjects, depts);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCatalogList(
    BuildContext context,
    List<SubjectModel> subjects,
    List<String> depts,
  ) {
    final q = _searchController.text.toLowerCase();
    final filtered = subjects.where((s) {
      final matchesDept = _selectedDept == 'All';
      final matchesQ = q.isEmpty ||
          s.subjectName.toLowerCase().contains(q) ||
          s.subjectId.toString().contains(q);
      return matchesDept && matchesQ;
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
            children: depts.map((dept) {
              final selected = dept == _selectedDept;
              return ChoiceChip(
                label: Text(dept),
                selected: selected,
                onSelected: (_) => setState(() => _selectedDept = dept),
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
              ? const Center(
                  child: Text(
                    'Không tìm thấy môn học nào.',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final subject = filtered[index];
                    return _CatalogCourseCard(
                      subject: subject,
                      onEnroll: () {
                        context
                            .read<EnrollmentBloc>()
                            .add(EnrollSubject(subject.subjectId));
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
  final VoidCallback onEnroll;

  const _CatalogCourseCard({required this.subject, required this.onEnroll});

  @override
  Widget build(BuildContext context) {
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
                  '${subject.subjectId} • ${subject.subjectName}',
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
                  color: subject.isActive
                      ? AppTheme.success.withOpacity(0.12)
                      : AppTheme.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  subject.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        subject.isActive ? AppTheme.success : AppTheme.warning,
                  ),
                ),
              ),
            ],
          ),
          if (subject.description != null &&
              subject.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subject.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textMuted),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: subject.isActive ? onEnroll : null,
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Enroll'),
            ),
          ),
        ],
      ),
    );
  }
}
