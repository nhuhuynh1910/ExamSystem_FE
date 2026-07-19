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

class CourseDetailsEditScreen extends StatelessWidget {
  final String courseCode;
  const CourseDetailsEditScreen({super.key, this.courseCode = '0'});

  @override
  Widget build(BuildContext context) {
    final subjectId = int.tryParse(courseCode) ?? 0;
    return BlocProvider(
      create: (_) => SubjectBloc(SubjectRepository())..add(LoadSubjectDetail(subjectId)),
      child: CourseDetailsEditContent(courseCode: courseCode, subjectId: subjectId),
    );
  }
}

class CourseDetailsEditContent extends StatefulWidget {
  final String courseCode;
  final int subjectId;
  const CourseDetailsEditContent({super.key, required this.courseCode, required this.subjectId});

  @override
  State<CourseDetailsEditContent> createState() =>
      _CourseDetailsEditContentState();
}

class _CourseDetailsEditContentState extends State<CourseDetailsEditContent> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedCategory = 'Core';
  int _selectedCredits = 3;
  String _selectedStatus = 'Active';

  bool _isLoaded = false;

  final List<String> _categories = ['Core', 'Elective', 'Specialization', 'Internship'];

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descController.dispose();
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
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Course Details',
          style: TextStyle(
            color: AppTheme.navy,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
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
        listenWhen: (_, state) => state is SubjectActionSuccess || state is SubjectFailure,
        listener: (context, state) {
          if (state is SubjectActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.success,
              ),
            );
            if (state.message.contains('xóa') || state.message.contains('Xóa') || state.message.contains('Delete')) {
              context.pop();
            } else {
              _isLoaded = false; // Reset to allow reload of controllers
              context.read<SubjectBloc>().add(LoadSubjectDetail(widget.subjectId));
            }
          } else if (state is SubjectFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.errorMessage}'),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        buildWhen: (_, state) => state is SubjectLoading || state is SubjectDetailLoaded,
        builder: (context, state) {
          if (state is SubjectLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SubjectDetailLoaded) {
            final subject = state.subject;
            if (!_isLoaded) {
              _codeController.text = subject.courseCode;
              _nameController.text = subject.courseNameOnly;
              _descController.text = subject.cleanDescription;
              _selectedCategory = subject.courseCategory;
              _selectedCredits = subject.courseCredits;
              _selectedStatus = subject.isActive ? 'Active' : 'Pending';
              _isLoaded = true;
            }

            String formatDate(DateTime dt) {
              return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
            }

            final lastEditStr = subject.updatedAt != null
                ? formatDate(subject.updatedAt!)
                : formatDate(subject.createdAt ?? DateTime.now());

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Section 1: Active Curriculum Header Card ────────────────────
                  Card(
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.border),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.school,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'ACTIVE CURRICULUM',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.primary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _nameController.text.isNotEmpty
                                          ? _nameController.text
                                          : 'Course Name',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.navy,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_codeController.text} • $_selectedCredits Credits',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Blue status banner
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0F2FE), // Light sky blue
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.verified_user_rounded,
                                color: Color(0xFF0369A1), // Sky blue dark
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Status: ${_selectedStatus == 'Active' ? 'Published' : 'Pending'}',
                                style: const TextStyle(
                                  color: Color(0xFF0369A1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Section 1.5: Course Management Actions Card ─────────────────
                  Card(
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.admin_panel_settings_rounded, color: AppTheme.primary, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Course Management Actions',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.navy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.primary,
                                      side: const BorderSide(color: AppTheme.primary, width: 1.2),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => context.push('/admin/courses/${widget.subjectId}/assign-teacher'),
                                    icon: const Icon(Icons.person_add_alt_rounded, size: 18),
                                    label: const Text(
                                      'Teachers',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.primary,
                                      side: const BorderSide(color: AppTheme.primary, width: 1.2),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => context.push('/admin/courses/${widget.subjectId}/students'),
                                    icon: const Icon(Icons.people_alt_rounded, size: 18),
                                    label: const Text(
                                      'Students',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Section 2: General Information Card ──────────────────────────
                  Card(
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'General Information',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.navy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Course Code'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _codeController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: _inputDecoration('e.g., SWE102'),
                            validator: (value) =>
                                (value == null || value.trim().isEmpty) ? 'Mã môn học là bắt buộc' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Credits'),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            value: _selectedCredits,
                            decoration: _inputDecoration('Select credits'),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            items: List.generate(10, (index) => index + 1).map((val) {
                              return DropdownMenuItem<int>(
                                value: val,
                                child: Text('$val Credits'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedCredits = val);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Course Name'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration('e.g., Software Engineering'),
                            validator: (value) =>
                                (value == null || value.trim().isEmpty) ? 'Tên môn học là bắt buộc' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Category'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _categories.map((cat) {
                              final selected = cat.toLowerCase() == _selectedCategory.toLowerCase();
                              return ChoiceChip(
                                label: Text(cat),
                                selected: selected,
                                onSelected: (_) {
                                  setState(() => _selectedCategory = cat);
                                },
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
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Status'),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            decoration: _inputDecoration('Select status'),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            items: ['Active', 'Pending'].map((status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedStatus = val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Section 3: Course Description Card ────────────────────────────
                  Card(
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.description_outlined, color: AppTheme.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Course Description',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.navy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descController,
                            maxLines: 4,
                            decoration: _inputDecoration('Syllabus, objectives, and outcomes...'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Section 4: Action Buttons ─────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _saveChanges,
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                      label: const Text(
                        'Save Changes',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: const BorderSide(color: AppTheme.error, width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showCustomDeleteDialog(context, subject),
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      label: const Text(
                        'Delete Course',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Last edited: $lastEditStr',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }

          return const Center(child: Text('Không tìm thấy thông tin môn học.'));
        },
      ),
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 1),
    );
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;
    final code = _codeController.text.trim();
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    context.read<SubjectBloc>().add(
          UpdateSubjectEvent(
            subjectId: widget.subjectId,
            subjectName: SubjectModel.toFormattedSubjectName(code, name),
            description: SubjectModel.toFormattedDescription(
              credits: _selectedCredits,
              category: _selectedCategory,
              rawDesc: desc,
            ),
            isActive: _selectedStatus == 'Active',
          ),
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
                    Navigator.pop(ctx); // Pop Dialog
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

  Widget _buildLabel(String labelText) {
    return Text(
      labelText,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textMuted,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
      ),
    );
  }
}
