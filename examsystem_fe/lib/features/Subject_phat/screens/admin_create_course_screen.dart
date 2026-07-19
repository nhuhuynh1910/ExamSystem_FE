import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/subject_bloc.dart';
import '../bloc/subject_event.dart';
import '../bloc/subject_state.dart';
import '../data/subject_repository.dart';
import '../models/subject_model.dart';

class AdminCreateCourseScreen extends StatelessWidget {
  const AdminCreateCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubjectBloc(SubjectRepository()),
      child: const _AdminCreateCourseContent(),
    );
  }
}

class _AdminCreateCourseContent extends StatefulWidget {
  const _AdminCreateCourseContent();

  @override
  State<_AdminCreateCourseContent> createState() =>
      _AdminCreateCourseContentState();
}

class _AdminCreateCourseContentState extends State<_AdminCreateCourseContent> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedCategory = 'Core';
  int _selectedCredits = 3;

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
          'Create New Course',
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
        listener: (context, state) {
          if (state is SubjectActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.success,
              ),
            );
            context.pop();
          } else if (state is SubjectFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.errorMessage}'),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is SubjectLoading;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Card 1: Course Identity ──────────────────────────────────────
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
                        _sectionTitle(Icons.badge_outlined, 'Course Identity'),
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
                        _buildLabel('Course Name'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration('e.g., Software Engineering'),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty) ? 'Tên môn học là bắt buộc' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Card 2: Academic Details ──────────────────────────────────────
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
                        _sectionTitle(Icons.school_outlined, 'Academic Details'),
                        const SizedBox(height: 16),
                        _buildLabel('Course Category'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _categories.map((cat) {
                            final selected = cat == _selectedCategory;
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Card 3: Course Description ─────────────────────────────────────
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
                        _sectionTitle(Icons.description_outlined, 'Course Description'),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descController,
                          maxLines: 4,
                          decoration: _inputDecoration('Detail the course syllabus, learning outcomes, and objectives...'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Bottom Action Buttons ──────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textMuted,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => context.pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: isSubmitting ? null : _submit,
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.add_circle, size: 20),
                          label: Text(
                            isSubmitting ? 'Creating...' : 'Create Course',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final code = _codeController.text.trim();
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    context.read<SubjectBloc>().add(
          CreateSubjectEvent(
            subjectName: SubjectModel.toFormattedSubjectName(code, name),
            description: SubjectModel.toFormattedDescription(
              credits: _selectedCredits,
              category: _selectedCategory,
              rawDesc: desc,
            ),
          ),
        );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.navy,
          ),
        ),
      ],
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
