import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/subject_bloc.dart';
import '../bloc/subject_event.dart';
import '../bloc/subject_state.dart';
import '../data/subject_repository.dart';

class CourseDetailsEditScreen extends StatelessWidget {
  final String courseCode;
  const CourseDetailsEditScreen({super.key, this.courseCode = 'PRN231'});

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
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _maxStudentsController = TextEditingController(text: '35');
  String _selectedStatus = 'Active';

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _maxStudentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text('Chi tiết môn học #${widget.courseCode}'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            icon: Icon(_isEditing ? Icons.close_rounded : Icons.edit_rounded),
          ),
        ],
      ),
      body: BlocConsumer<SubjectBloc, SubjectState>(
        listenWhen: (_, state) => state is SubjectActionSuccess || state is SubjectFailure,
        listener: (context, state) {
          if (state is SubjectActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            setState(() => _isEditing = false);
            context.read<SubjectBloc>().add(LoadSubjectDetail(widget.subjectId));
          } else if (state is SubjectFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${state.errorMessage}')),
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
            // Chỉ cập nhật controller khi không ở trạng thái chỉnh sửa để tránh ghi đè dữ liệu đang gõ
            if (!_isEditing) {
              _nameController.text = subject.subjectName;
              _descController.text = subject.description ?? '';
              _selectedStatus = subject.isActive ? 'Active' : 'Pending';
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Môn học ID',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${subject.subjectId}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.navy,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        'Tên môn học',
                        _nameController,
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        'Mô tả',
                        _descController,
                        enabled: _isEditing,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        'Số sinh viên tối đa',
                        _maxStudentsController,
                        enabled: _isEditing,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      if (_isEditing)
                        DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          items: ['Active', 'Pending']
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(
                            () => _selectedStatus = value ?? _selectedStatus,
                          ),
                          decoration: _inputDecoration('Trạng thái'),
                        )
                      else
                        _infoRow('Trạng thái', _selectedStatus),
                      const SizedBox(height: 16),
                      if (_isEditing)
                        FilledButton.icon(
                          onPressed: () {
                            context.read<SubjectBloc>().add(
                                  UpdateSubjectEvent(
                                    subjectId: widget.subjectId,
                                    subjectName: _nameController.text.trim(),
                                    description: _descController.text.trim(),
                                    isActive: _selectedStatus == 'Active',
                                  ),
                                );
                          },
                          icon: const Icon(Icons.save_rounded),
                          label: const Text('Lưu thay đổi'),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Không tìm thấy thông tin môn học.'));
        },
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool enabled = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 6),
        enabled
            ? TextFormField(
                controller: controller,
                maxLines: maxLines,
                keyboardType: keyboardType,
                decoration: _inputDecoration(label),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.lightBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  controller.text,
                  style: const TextStyle(color: AppTheme.navy),
                ),
              ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(color: AppTheme.textMuted)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.navy,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
