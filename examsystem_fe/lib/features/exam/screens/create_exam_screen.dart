import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../bloc/exam_bloc.dart';
import '../bloc/exam_event.dart';
import '../bloc/exam_state.dart';
import '../models/add_exam_question_request.dart';
import '../models/exam_create_request.dart';
import '../models/subject_model.dart';
import '../../question/bloc/question_bloc.dart';
import '../../question/bloc/question_event.dart' as qe;
import '../../question/bloc/question_state.dart' as qs;

class CreateExamScreen extends StatefulWidget {
  const CreateExamScreen({super.key});

  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1: Info
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  int? _subjectId;

  // Step 2: Questions Selection
  final List<int> _selectedQuestionIds = [];
  final Map<int, double> _questionScores = {};

  // Step 3: Settings
  final _durationController = TextEditingController(text: '60');
  final _totalScoreController = TextEditingController(text: '10');
  final _passingScoreController = TextEditingController(text: '5');
  final _attemptsController = TextEditingController(text: '1');
  bool _isPrivate = false;
  final _accessCodeController = TextEditingController();
  DateTime _startTime = DateTime.now().add(const Duration(hours: 1));
  DateTime _endTime = DateTime.now().add(const Duration(days: 7));
  bool _shuffleQuestions = true;
  bool _showAnswerAfterSubmit = true;

  // Step 4: Image
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<ExamBloc>().add(const LoadTeacherSubjectsEvent());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _durationController.dispose();
    _totalScoreController.dispose();
    _passingScoreController.dispose();
    _attemptsController.dispose();
    _accessCodeController.dispose();
    super.dispose();
  }

  void _loadQuestionsForSubject() {
    if (_subjectId != null) {
      context.read<QuestionBloc>().add(qe.LoadQuestionsEvent(queryParameters: {'subjectId': _subjectId, 'status': 'Published'}));
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = image.name;
      });
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _startTime : _endTime,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStart ? _startTime : _endTime),
      );

      if (pickedTime != null) {
        setState(() {
          final newDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
          if (isStart) {
            _startTime = newDateTime;
            if (_endTime.isBefore(_startTime)) _endTime = _startTime.add(const Duration(days: 1));
          } else {
            _endTime = newDateTime;
          }
        });
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ảnh bìa')));
        return;
      }

      final request = ExamCreateRequest(
        subjectId: _subjectId!,
        examName: _nameController.text,
        description: _descController.text,
        durationMinutes: int.parse(_durationController.text),
        startTime: _startTime,
        endTime: _endTime,
        totalScore: double.parse(_totalScoreController.text),
        passingScore: double.parse(_passingScoreController.text),
        maxAttempts: int.parse(_attemptsController.text),
        isPrivate: _isPrivate,
        accessCode: _isPrivate ? _accessCodeController.text : null,
        shuffleQuestions: _shuffleQuestions,
        showAnswerAfterSubmit: _showAnswerAfterSubmit,
        examImageBytes: _selectedImageBytes,
        examImageName: _selectedImageName,
      );

      final List<AddExamQuestionRequest> questions = _selectedQuestionIds.asMap().entries.map((entry) {
        final qId = entry.value;
        return AddExamQuestionRequest(
          questionId: qId,
          questionOrder: entry.key + 1,
          score: _questionScores[qId] ?? 0.0,
        );
      }).toList();

      context.read<ExamBloc>().add(CreateExamEvent(request, questions: questions));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Create New Exam', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: BlocListener<ExamBloc, ExamState>(
        listener: (context, state) {
          if (state is ExamOperationSuccess) Navigator.pop(context);
        },
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildStepIndicator(),
              Expanded(
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    _buildInfoStep(),
                    _buildQuestionsStep(),
                    _buildSettingsStep(),
                    _buildPreviewStep(),
                  ],
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Details', 'Questions', 'Settings', 'Preview'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(steps.length, (index) {
          final isCompleted = index < _currentStep;
          final isActive = index == _currentStep;
          return Row(
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isActive || isCompleted ? const Color(0xFFF97316) : Colors.grey[200],
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text('${index + 1}', style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontSize: 12)),
                  ),
                  const SizedBox(height: 4),
                  Text(steps[index], style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? const Color(0xFFF97316) : Colors.grey)),
                ],
              ),
              if (index < steps.length - 1)
                Container(
                  width: 40,
                  height: 2,
                  margin: const EdgeInsets.only(left: 8, right: 8, bottom: 15),
                  color: index < _currentStep ? const Color(0xFFF97316) : Colors.grey[200],
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildInfoStep() {
    return BlocBuilder<ExamBloc, ExamState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('BASIC INFORMATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFF97316), letterSpacing: 1.1)),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                initialValue: _subjectId,
                isExpanded: true,
                menuMaxHeight: 400,
                decoration: InputDecoration(
                  labelText: state.isLoading 
                      ? 'Loading Subjects...' 
                      : 'Subject (${state.subjects.length} assigned)',
                  prefixIcon: Icon(Icons.book_outlined, color: _subjectId == null ? Colors.grey : const Color(0xFFF97316)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                  suffixIcon: state.isLoading ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))) : null,
                ),
                items: state.subjects.isEmpty
                    ? []
                    : state.subjects.map((s) => DropdownMenuItem(
                          value: s.subjectId,
                          child: Text(s.subjectName, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                        )).toList(),
                onChanged: state.isLoading ? null : (v) {
                  setState(() {
                    _subjectId = v;
                    _selectedQuestionIds.clear(); // Xóa câu hỏi cũ khi đổi môn
                    _questionScores.clear();
                  });
                  if (v != null) {
                    context.read<QuestionBloc>().add(qe.LoadQuestionsEvent(
                      queryParameters: {'subjectId': v, 'status': 'Published'}
                    ));
                  }
                },
                validator: (v) => v == null ? 'Please select a subject' : null,
                hint: Text(
                  state.subjects.isEmpty
                      ? (state.isLoading ? 'Loading...' : 'No subjects assigned to you') 
                      : 'Select a subject',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Exam Name',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                ),
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 30),
              const Text('COVER IMAGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFF97316), letterSpacing: 1.1)),
              const SizedBox(height: 16),
              _buildImagePicker(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePicker() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]),
        child: _selectedImageBytes != null
            ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [Icon(Icons.add_photo_alternate_outlined, size: 40, color: Color(0xFFF97316)), SizedBox(height: 8), Text('Upload Exam Cover', style: TextStyle(color: Colors.grey, fontSize: 13))],
              ),
      ),
    );
  }

  Widget _buildQuestionsStep() {
    return BlocBuilder<QuestionBloc, qs.QuestionState>(
      builder: (context, state) {
        final questions = state.questions ?? [];
        if (_subjectId == null) return const Center(child: Text('Please select a subject first'));
        if (state.isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Text('Question Bank (${questions.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  Text('${_selectedQuestionIds.length} Selected', style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final q = questions[index];
                  final isSelected = _selectedQuestionIds.contains(q.questionId);
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFFF97316)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: CheckboxListTile(
                      value: isSelected,
                      activeColor: const Color(0xFFF97316),
                      onChanged: (v) {
                        setState(() {
                          if (v!) {
                            _selectedQuestionIds.add(q.questionId);
                            _questionScores[q.questionId] = q.score;
                          } else {
                            _selectedQuestionIds.remove(q.questionId);
                          }
                        });
                      },
                      title: Text(q.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      subtitle: Text('${q.difficulty} • ${q.score} pts', style: const TextStyle(fontSize: 12)),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('TIME & SCHEDULE', Icons.timer_outlined),
          _buildTextField(_durationController, 'Duration (Mins)', Icons.access_time),
          const SizedBox(height: 16),
          _buildDateTimePickerTile('Start Date & Time', _startTime, () => _pickDateTime(isStart: true)),
          _buildDateTimePickerTile('End Date & Time', _endTime, () => _pickDateTime(isStart: false)),
          const SizedBox(height: 32),
          _sectionTitle('EXAM RULES', Icons.rule_folder_outlined),
          Row(
            children: [
              Expanded(child: _buildTextField(_attemptsController, 'Max Attempts', Icons.repeat)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_passingScoreController, 'Passing Score', Icons.check_circle_outline)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(_totalScoreController, 'Total Points', Icons.grade_outlined),
          const SizedBox(height: 16),
          SwitchListTile(title: const Text('Shuffle Questions', style: TextStyle(fontSize: 14)), value: _shuffleQuestions, activeColor: const Color(0xFFF97316), onChanged: (v) => setState(() => _shuffleQuestions = v)),
          SwitchListTile(title: const Text('Show Answer After Submit', style: TextStyle(fontSize: 14)), value: _showAnswerAfterSubmit, activeColor: const Color(0xFFF97316), onChanged: (v) => setState(() => _showAnswerAfterSubmit = v)),
          const SizedBox(height: 32),
          _sectionTitle('SECURITY', Icons.lock_outline),
          SwitchListTile(title: const Text('Private Exam', style: TextStyle(fontSize: 14)), subtitle: const Text('Requires access code'), value: _isPrivate, activeColor: const Color(0xFFF97316), onChanged: (v) => setState(() => _isPrivate = v)),
          if (_isPrivate) _buildTextField(_accessCodeController, 'Access Code', Icons.vpn_key_outlined),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(children: [Icon(icon, size: 18, color: const Color(0xFFF97316)), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFF97316), letterSpacing: 1.1))]),
    );
  }

  Widget _buildDateTimePickerTile(String label, DateTime dt, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(dt), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.calendar_month, color: Color(0xFFF97316), size: 20),
      onTap: onTap,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      ),
    );
  }

  Widget _buildPreviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[100]!)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('FINAL ASSESSMENT', style: TextStyle(color: Color(0xFFF97316), fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(_nameController.text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF97316).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Column(children: [Text(_totalScoreController.text, style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 18)), const Text('POINTS', style: TextStyle(color: Color(0xFFF97316), fontSize: 8, fontWeight: FontWeight.bold))]),
                    ),
                  ],
                ),
                const Divider(height: 40),
                _previewInfoItem(Icons.book_outlined, 'Subject', 'Subject ID: $_subjectId'),
                const SizedBox(height: 12),
                _previewInfoItem(Icons.quiz_outlined, 'Questions', '${_selectedQuestionIds.length} items'),
                const SizedBox(height: 32),
                _sectionTitle('CONFIGURATION', Icons.settings_outlined),
                _previewDetailRow('Duration', '${_durationController.text} min'),
                _previewDetailRow('Attempts', _attemptsController.text),
                _previewDetailRow('Access', _isPrivate ? 'Private' : 'Public'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Ready to launch your exam?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Text('Double-check all configurations before publishing. Some settings cannot be changed later.', style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _previewInfoItem(IconData icon, String label, String value) {
    return Row(children: [Icon(icon, size: 20, color: Colors.grey), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))])]);
  }

  Widget _previewDetailRow(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]));
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), side: const BorderSide(color: Color(0xFFF97316))),
                child: const Text('Previous', style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (_currentStep == 0) {
                  // Bắt buộc chọn Subject và nhập tên đề mới cho qua bước tiếp theo
                  if (_formKey.currentState!.validate()) {
                    _loadQuestionsForSubject();
                    setState(() => _currentStep++);
                  }
                } else if (_currentStep < 3) {
                  setState(() => _currentStep++);
                } else {
                  _submit();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316), foregroundColor: Colors.white, minimumSize: const Size(0, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
              child: Text(_currentStep == 3 ? 'Publish Exam' : 'Next Step', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
