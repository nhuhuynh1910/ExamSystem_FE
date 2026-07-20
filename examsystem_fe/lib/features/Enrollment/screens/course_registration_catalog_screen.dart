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
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'All',
      'Core',
      'Elective',
      'Specialization',
      'Internship',
    ];

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      // ── App Bar ──────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            const Icon(Icons.library_books_rounded, color: AppTheme.primary),
            const SizedBox(width: 8),
            const Text(
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
            onPressed: () => context.go('/student/courses/registered'),
            icon: const Icon(Icons.fact_check_rounded, color: AppTheme.primary, size: 26),
            tooltip: 'Môn đã đăng ký',
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
            return _buildCatalogList(context, state.subjects, categories);
          }

          return const SizedBox.shrink();
        },
      ),
      // Sub-screen: navigation via AppBar back/home button
    );
  }

  Widget _buildCatalogList(
    BuildContext context,
    List<SubjectModel> subjects,
    List<String> categories,
  ) {
    final q = _searchController.text.toLowerCase();
    final filtered = subjects.where((s) {
      final matchesCat = _selectedCategory == 'All' ||
          s.courseCategory.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesQ = q.isEmpty ||
          s.courseCode.toLowerCase().contains(q) ||
          s.courseNameOnly.toLowerCase().contains(q);
      return matchesCat && matchesQ;
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

        // Category Choice chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: categories.map((cat) {
                final selected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: AppTheme.primary,
                    backgroundColor: Colors.white,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppTheme.textMuted,
                      fontWeight: FontWeight.bold,
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
        ),
        const SizedBox(height: 12),

        // List
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'Không tìm thấy môn học nào.',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
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
    final cat = subject.courseCategory;

    return Container(
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
          // Header Row: Category & Status
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: subject.isActive
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    subject.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: subject.isActive ? Colors.green : Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Course Code & Name
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.courseCode,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subject.courseNameOnly,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Description
          if (subject.cleanDescription.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                subject.cleanDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          const SizedBox(height: 12),

          // Bottom Bar
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
                    const Icon(Icons.menu_book_rounded, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${subject.courseCredits} Credits',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 36,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    onPressed: subject.isActive ? onEnroll : null,
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                    label: const Text(
                      'Enroll',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
