import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../common/admin_bottom_nav_bar.dart';
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
      // ── App Bar ──────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.primary),
          onPressed: () {},
        ),
        title: const Text(
          'Course Management',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await context.push('/admin/courses/create');
              if (mounted) {
                context.read<SubjectBloc>().add(LoadSubjects());
              }
            },
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primary, size: 28),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary, width: 1.5),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDkjuVzVcYsKpzjWu50v7GrxIhms3Ht071Ukj4M0xvWimL32hVzhyPQ91c4_uBLcAk4gSqDFyc9vndErcgymigMCtutHjWes2bMLbZMBS4YT0KFpFkj_GwStus7jdObLiaGA5guyYveAxlff9gnl2s8Owu0-a7NXlPPowYRF8TdCo6H8GDGg7UlvWMG9IOXuvNIpb_ErAFDN75oaWd0pOQI0rBZ_Fr7L5UemYD8yRQynqpnrhsoneSA0K_yUUC6pK_u1C13BKUSX7A',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<SubjectBloc, SubjectState>(
        listenWhen: (_, state) => state is SubjectActionSuccess,
        listener: (context, state) {
          if (state is SubjectActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.success,
              ),
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
                  c.courseCode.toLowerCase().contains(q) ||
                  c.courseNameOnly.toLowerCase().contains(q);
              return matchesFilter && matchesSearch;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Info & Subtitle
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Course Inventory',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Manage ${filtered.length} active courses for Summer Semester 2024',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search course code or name...',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
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

                // Filter choice chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: filters.map((filter) {
                      final selected = filter == _selectedFilter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedFilter = filter),
                          selectedColor: AppTheme.primary,
                          backgroundColor: Colors.white,
                          disabledColor: Colors.grey.shade100,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: selected ? AppTheme.primary : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // Course list
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('Không tìm thấy môn học nào.'))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (ctx, index) {
                            final course = filtered[index];
                            return _CourseManagementCard(
                              course: course,
                              onDelete: () => _showCustomDeleteDialog(context, course),
                              onEdit: () async {
                                await context.push('/admin/courses/${course.subjectId}');
                                if (context.mounted) {
                                  context.read<SubjectBloc>().add(LoadSubjects());
                                }
                              },
                              onToggleStatus: (newStatus) {
                                context.read<SubjectBloc>().add(
                                      UpdateSubjectEvent(
                                        subjectId: course.subjectId,
                                        subjectName: course.subjectName,
                                        description: course.description ?? '',
                                        isActive: newStatus,
                                      ),
                                    );
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
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 1),
    );
  }

  void _showCustomDeleteDialog(BuildContext context, SubjectModel course) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular Warning Badge
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2), // light red
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.error,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              // Title
              const Text(
                'Delete Course?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navy,
                ),
              ),
              const SizedBox(height: 10),
              // Content description
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 14, height: 1.4),
                  children: [
                    const TextSpan(text: 'Are you sure you want to delete '),
                    TextSpan(
                      text: "'${course.courseNameOnly} (${course.courseCode})'",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navy),
                    ),
                    const TextSpan(text: '? This action cannot be undone.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Stacked Buttons
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.read<SubjectBloc>().add(DeleteSubjectEvent(course.subjectId));
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  label: const Text(
                    'Delete',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textMuted,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseManagementCard extends StatelessWidget {
  final SubjectModel course;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggleStatus;

  const _CourseManagementCard({
    required this.course,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleStatus,
  });

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'CORE':
        return const Color(0xFFEFF6FF); // Soft blue
      case 'PROGRAMMING':
        return const Color(0xFFFDF2F8); // Soft pink
      case 'SYSTEMS':
        return const Color(0xFFECFDF5); // Soft green
      case 'MATH':
        return const Color(0xFFFFF7ED); // Soft orange
      case 'CAPSTONE':
        return const Color(0xFFF5F3FF); // Soft purple
      default:
        return const Color(0xFFF1F5F9); // Soft gray
    }
  }

  Color _getCategoryTextColor(String category) {
    switch (category.toUpperCase()) {
      case 'CORE':
        return const Color(0xFF1D4ED8);
      case 'PROGRAMMING':
        return const Color(0xFFBE185D);
      case 'SYSTEMS':
        return const Color(0xFF047857);
      case 'MATH':
        return const Color(0xFFC2410C);
      case 'CAPSTONE':
        return const Color(0xFF6D28D9);
      default:
        return const Color(0xFF475569);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat = course.courseCategory;

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: Tag & Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Category Chip Tag & Status Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(cat),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        cat.toUpperCase(),
                        style: TextStyle(
                          color: _getCategoryTextColor(cat),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: course.isActive
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        course.isActive ? 'ACTIVE' : 'PENDING',
                        style: TextStyle(
                          color: course.isActive ? Colors.green : Colors.red,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // Switch Toggle & Actions
                Row(
                  children: [
                    SizedBox(
                      height: 20,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Switch(
                          value: course.isActive,
                          activeColor: Colors.green,
                          activeTrackColor: Colors.green.shade100,
                          inactiveThumbColor: Colors.grey.shade400,
                          inactiveTrackColor: Colors.grey.shade200,
                          onChanged: (val) {
                            onToggleStatus(val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.mode_edit_outline_outlined, color: AppTheme.textMuted, size: 20),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 20),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Course Code & Name
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
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

          // Bottom Stats Row (Credits & Groups) and Action shortcut buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Credits Info
                    Row(
                      children: [
                        const Icon(Icons.menu_book_rounded, size: 16, color: AppTheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${course.courseCredits} Credits',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Tiny shortcuts for secondary features
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/admin/courses/${course.subjectId}/assign-teacher'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          '+ Teacher',
                          style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => context.push('/admin/courses/${course.subjectId}/students'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'Students',
                          style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),);
  }
}
