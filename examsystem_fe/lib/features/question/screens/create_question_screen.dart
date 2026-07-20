import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/question_bloc.dart';
import '../bloc/question_event.dart';
import '../bloc/question_state.dart';
import '../../exam/models/subject_model.dart';

class CreateQuestionScreen extends StatefulWidget {
  const CreateQuestionScreen({super.key});

  @override
  State<CreateQuestionScreen> createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedDifficulty = 'Easy';
  double _score = 1;
  int? _selectedSubjectId;

  final _questionController = TextEditingController();
  final _explanationController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  int _correctIndex = 0;

  static const Color primaryColor = Color(0xFFF97316);

  @override
  void initState() {
    super.initState();
    context.read<QuestionBloc>().add(const LoadSubjectsEvent());
  }

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    for (var c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) return;
    setState(() {
      _optionControllers.removeAt(index);
      if (_correctIndex >= _optionControllers.length) {
        _correctIndex = 0;
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a subject')));
      return;
    }

    final Map<String, dynamic> questionData = {
      'subjectId': _selectedSubjectId,
      'content': _questionController.text.trim(),
      'questionType': 'MultipleChoice',
      'difficulty': _selectedDifficulty,
      'score': _score,
      'explanation': _explanationController.text.trim().isEmpty ? null : _explanationController.text.trim(),
    };

    final options = _optionControllers.asMap().entries.map((e) {
      return {
        'optionText': e.value.text.trim(),
        'isCorrect': e.key == _correctIndex,
        'optionOrder': e.key + 1,
      };
    }).toList();

    context.read<QuestionBloc>().add(CreateQuestionEvent(questionData, options));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuestionBloc, QuestionState>(
      listener: (context, state) {
        if (state is QuestionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!), backgroundColor: Colors.green));
          Navigator.pop(context);
        } else if (state is QuestionError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!), backgroundColor: Colors.red));
        }
      },
      builder: (context, state) {
        final subjects = state.subjects ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text('New Question', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (state.isLoading)
                const Center(child: Padding(padding: EdgeInsets.only(right: 16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor))))
              else
                TextButton(
                  onPressed: _save,
                  child: const Text('SAVE', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildCard([
                  _buildLabel('SUBJECT'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _selectedSubjectId,
                    isExpanded: true,
                    decoration: _inputDecoration('Select subject', Icons.book_outlined),
                    items: subjects.map((s) => DropdownMenuItem(value: s.subjectId, child: Text(s.subjectName))).toList(),
                    onChanged: (v) => setState(() => _selectedSubjectId = v),
                    validator: (v) => v == null ? 'Please select a subject' : null,
                  ),
                ]),
                const SizedBox(height: 20),
                _buildCard([
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('DIFFICULTY'),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _selectedDifficulty,
                              decoration: _inputDecoration('', Icons.speed),
                              items: ['Easy', 'Medium', 'Hard'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                              onChanged: (v) => setState(() => _selectedDifficulty = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('SCORE'),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<double>(
                              value: _score,
                              decoration: _inputDecoration('', Icons.stars_outlined),
                              items: List.generate(10, (i) => (i + 1).toDouble()).map((s) => DropdownMenuItem(value: s, child: Text(s.toStringAsFixed(0)))).toList(),
                              onChanged: (v) => setState(() => _score = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 20),
                _buildCard([
                  _buildLabel('QUESTION CONTENT'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _questionController,
                    maxLines: 4,
                    decoration: _inputDecoration('Enter question content...', null),
                    validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('EXPLANATION (OPTIONAL)'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _explanationController,
                    maxLines: 2,
                    decoration: _inputDecoration('Explain the answer...', null),
                  ),
                ]),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Text('ANSWER OPTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B), letterSpacing: 1.1)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _addOption,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Option', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(foregroundColor: primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...List.generate(_optionControllers.length, (index) => _buildOptionRow(index)),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: state.isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: state.isLoading 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text('SAVE QUESTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B), letterSpacing: 1.1));
  }

  InputDecoration _inputDecoration(String hint, IconData? icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: 20, color: const Color(0xFF64748B)) : null,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  Widget _buildOptionRow(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: index == _correctIndex ? primaryColor.withOpacity(0.5) : const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Radio<int>(
              value: index,
              groupValue: _correctIndex,
              activeColor: primaryColor,
              onChanged: (v) => setState(() => _correctIndex = v!),
            ),
            Expanded(
              child: TextFormField(
                controller: _optionControllers[index],
                decoration: const InputDecoration(hintText: 'Enter option text...', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
            ),
            if (_optionControllers.length > 2)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                onPressed: () => _removeOption(index),
              ),
          ],
        ),
      ),
    );
  }
}
