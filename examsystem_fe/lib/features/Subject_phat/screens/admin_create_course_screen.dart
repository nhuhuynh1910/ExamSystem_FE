import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/subject_bloc.dart';
import '../bloc/subject_event.dart';
import '../bloc/subject_state.dart';
import '../data/subject_repository.dart';

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
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Tạo môn học mới'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.navy,
        elevation: 0,
      ),
      body: BlocConsumer<SubjectBloc, SubjectState>(
        listener: (context, state) {
          if (state is SubjectActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.pop();
          } else if (state is SubjectFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${state.errorMessage}')),
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
                _sectionTitle('Thông tin chung'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('Tên môn học', Icons.title_rounded),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Bắt buộc' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  decoration: _inputDecoration('Mô tả', Icons.description_rounded),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
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
                      : const Icon(Icons.save_rounded),
                  label: Text(isSubmitting ? 'Đang lưu...' : 'Lưu môn học'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<SubjectBloc>().add(
          CreateSubjectEvent(
            subjectName: _nameController.text.trim(),
            description: _descController.text.trim(),
          ),
        );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppTheme.navy,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppTheme.textMuted),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
