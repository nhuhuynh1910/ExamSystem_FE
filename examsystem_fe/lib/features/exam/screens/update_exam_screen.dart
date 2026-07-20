import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../bloc/exam_bloc.dart';
import '../bloc/exam_event.dart';
import '../bloc/exam_state.dart';
import '../models/exam_model.dart';
import '../models/exam_update_request.dart';
import '../models/subject_model.dart';

class UpdateExamScreen extends StatefulWidget {
  final ExamModel exam;
  const UpdateExamScreen({super.key, required this.exam});

  @override
  State<UpdateExamScreen> createState() => _UpdateExamScreenState();
}

class _UpdateExamScreenState extends State<UpdateExamScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late int _subjectId;
  late TextEditingController _durationController;
  late TextEditingController _totalScoreController;
  late TextEditingController _passingScoreController;
  late TextEditingController _attemptsController;
  late bool _isPrivate;
  late TextEditingController _accessCodeController;
  late DateTime _startTime;
  late DateTime _endTime;
  late bool _shuffleQuestions;
  late bool _showAnswerAfterSubmit;
  
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exam.examName);
    _descController = TextEditingController(text: widget.exam.description);
    _subjectId = widget.exam.subjectId;
    _durationController = TextEditingController(text: widget.exam.durationMinutes.toString());
    _totalScoreController = TextEditingController(text: widget.exam.totalScore.toString());
    _passingScoreController = TextEditingController(text: widget.exam.passingScore.toString());
    _attemptsController = TextEditingController(text: widget.exam.maxAttempts.toString());
    _isPrivate = widget.exam.isPrivate;
    _accessCodeController = TextEditingController(text: widget.exam.accessCode);
    _startTime = widget.exam.startTime ?? DateTime.now();
    _endTime = widget.exam.endTime ?? DateTime.now().add(const Duration(hours: 1));
    _shuffleQuestions = widget.exam.shuffleQuestions;
    _showAnswerAfterSubmit = widget.exam.showAnswerAfterSubmit;
    
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
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStart ? _startTime : _endTime),
      );

      if (pickedTime != null) {
        setState(() {
          final newDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStart) {
            _startTime = newDateTime;
            if (_endTime.isBefore(_startTime)) {
              _endTime = _startTime.add(const Duration(days: 1));
            }
          } else {
            _endTime = newDateTime;
          }
        });
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final double totalScore = double.parse(_totalScoreController.text);
      final double passingScore = double.parse(_passingScoreController.text);

      if (passingScore > totalScore) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Điểm đạt không được lớn hơn tổng điểm')));
        return;
      }

      if (_startTime.isAfter(_endTime) || _startTime.isAtSameMomentAs(_endTime)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thời gian bắt đầu phải trước thời gian kết thúc')));
        return;
      }

      final request = ExamUpdateRequest(
        subjectId: _subjectId,
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

      context.read<ExamBloc>().add(UpdateExamEvent(widget.exam.examId, request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Update Exam', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
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
                    _buildSettingsStep(),
                    _buildImageStep(),
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
    final steps = ['Info', 'Settings', 'Cover', 'Preview'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(steps.length, (index) {
          final isActive = index <= _currentStep;
          return Row(
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isActive ? const Color(0xFFF97316) : Colors.grey[200],
                    child: Text('${index + 1}', style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontSize: 12)),
                  ),
                  const SizedBox(height: 4),
                  Text(steps[index], style: TextStyle(fontSize: 10, color: isActive ? Colors.black : Colors.grey)),
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
        final subjects = state.subjects ?? [];
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<int>(
                value: _subjectId,
                decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                items: state.subjects.map((s) => DropdownMenuItem(value: s.subjectId, child: Text(s.subjectName))).toList(),
                onChanged: (v) => setState(() => _subjectId = v!),
                validator: (v) => v == null ? 'Please select a subject' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Exam Name', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                maxLines: 4,
              ),
            ],
          ),
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
          Row(
            children: [
              Expanded(child: _buildTextField(_durationController, 'Duration (Mins)', Icons.timer_outlined)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_attemptsController, 'Attempts', Icons.person_outline)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildTextField(_totalScoreController, 'Total Score', Icons.grade_outlined)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_passingScoreController, 'Passing Score', Icons.check_circle_outline)),
            ],
          ),
          const Divider(height: 40),
          const Text('Scheduling', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _buildDateTimePickerTile('Start Time', _startTime, () => _pickDateTime(isStart: true)),
          _buildDateTimePickerTile('End Time', _endTime, () => _pickDateTime(isStart: false)),
          const Divider(height: 40),
          SwitchListTile(
            title: const Text('Private Exam', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Require access code to join'),
            value: _isPrivate,
            activeColor: const Color(0xFFF97316),
            onChanged: (v) => setState(() => _isPrivate = v),
          ),
          if (_isPrivate)
            _buildTextField(_accessCodeController, 'Access Code', Icons.lock_open),
          SwitchListTile(
            title: const Text('Shuffle Questions'),
            value: _shuffleQuestions,
            onChanged: (v) => setState(() => _shuffleQuestions = v),
          ),
          SwitchListTile(
            title: const Text('Show Answers After Submit'),
            value: _showAnswerAfterSubmit,
            onChanged: (v) => setState(() => _showAnswerAfterSubmit = v),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePickerTile(String label, DateTime dt, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(dt), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.calendar_month, color: Color(0xFFF97316)),
      onTap: onTap,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
    );
  }

  Widget _buildImageStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_selectedImageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.memory(_selectedImageBytes!, height: 200, width: 300, fit: BoxFit.cover),
            )
          else if (widget.exam.examImageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(widget.exam.examImageUrl!, height: 200, width: 300, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 64)),
            )
          else
            Container(
              height: 200, width: 300,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid)),
              child: const Icon(Icons.image_outlined, size: 64, color: Colors.grey),
            ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Change Cover Image'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Review Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Divider(height: 32),
                _previewRow('Name', _nameController.text),
                _previewRow('Duration', '${_durationController.text} Mins'),
                _previewRow('Starts', DateFormat('dd/MM HH:mm').format(_startTime)),
                _previewRow('Ends', DateFormat('dd/MM HH:mm').format(_endTime)),
                _previewRow('Score', '${_passingScoreController.text} / ${_totalScoreController.text}'),
                _previewRow('Access', _isPrivate ? 'Private' : 'Public'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _previewRow(String l, String v) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Text('$l:', style: const TextStyle(color: Colors.grey)), const SizedBox(width: 8), Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right))]));

  Widget _buildFooter() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep--),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), side: const BorderSide(color: Color(0xFFF97316))),
                  child: const Text('Previous', style: TextStyle(color: Color(0xFFF97316))),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_currentStep < 3) {
                    setState(() => _currentStep++);
                  } else {
                    _submit();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316), foregroundColor: Colors.white, minimumSize: const Size(0, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text(_currentStep == 3 ? 'SAVE CHANGES' : 'Next', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
