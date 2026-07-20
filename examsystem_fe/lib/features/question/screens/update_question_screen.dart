import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/question_bloc.dart';
import '../bloc/question_event.dart';
import '../bloc/question_state.dart';
import '../models/question_model.dart';
import '../../exam/models/subject_model.dart';

class UpdateQuestionScreen extends StatefulWidget {
  final QuestionModel question;
  const UpdateQuestionScreen({super.key, required this.question});

  @override
  State<UpdateQuestionScreen> createState() => _UpdateQuestionScreenState();
}

class _UpdateQuestionScreenState extends State<UpdateQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedDifficulty;
  late double _score;
  late int? _selectedSubjectId;

  late TextEditingController _questionController;
  late TextEditingController _explanationController;
  final List<TextEditingController> _optionControllers = [];
  final List<int?> _optionIds = []; 

  int _correctIndex = 0;
  final List<int> _deletedOptionIds = [];

  static const Color primaryColor = Color(0xFFF97316);

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.question.difficulty.isNotEmpty ? widget.question.difficulty : 'Easy';
    _score = widget.question.score;
    _selectedSubjectId = widget.question.subjectId;
    _questionController = TextEditingController(text: widget.question.content);
    _explanationController = TextEditingController(text: widget.question.explanation ?? '');

    for (int i = 0; i < widget.question.options.length; i++) {
      final opt = widget.question.options[i];
      _optionControllers.add(TextEditingController(text: opt.optionText));
      _optionIds.add(opt.optionId);
      if (opt.isCorrect == true) {
        _correctIndex = i;
      }
    }

    // Ensure at least two options exist
    while (_optionControllers.length < 2) {
      _optionControllers.add(TextEditingController());
      _optionIds.add(null);
    }
    
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
      _optionIds.add(null);
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question must have at least 2 options')),
      );
      return;
    }
    setState(() {
      final id = _optionIds[index];
      if (id != null) {
        _deletedOptionIds.add(id);
      }
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
      _optionIds.removeAt(index);
      
      if (_correctIndex == index) {
        _correctIndex = 0;
      } else if (_correctIndex > index) {
        _correctIndex--;
      }
    });
  }

  bool _hasDuplicateOptions() {
    final options = _optionControllers
        .map((c) => c.text.trim().toLowerCase())
        .where((text) => text.isNotEmpty)
        .toList();
    return options.toSet().length != options.length;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a subject')));
      return;
    }

    if (_hasDuplicateOptions()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Answer options must not be duplicated'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final questionData = {
      'subjectId': _selectedSubjectId,
      'content': _questionController.text.trim(),
      'questionType': widget.question.questionType.isNotEmpty ? widget.question.questionType : 'MultipleChoice',
      'difficulty': _selectedDifficulty,
      'score': _score,
      'explanation': _explanationController.text.trim().isEmpty ? null : _explanationController.text.trim(),
      'rowVersion': widget.question.rowVersion,
    };

    final List<Map<String, dynamic>> newOptions = [];
    final List<Map<String, dynamic>> updatedOptions = [];

    for (int i = 0; i < _optionControllers.length; i++) {
      final Map<String, dynamic> optionBody = {
        'optionText': _optionControllers[i].text.trim(),
        'isCorrect': i == _correctIndex,
        'optionOrder': i + 1,
      };

      if (_optionIds[i] == null) {
        newOptions.add(optionBody);
      } else {
        optionBody['optionId'] = _optionIds[i];
        updatedOptions.add(optionBody);
      }
    }

    context.read<QuestionBloc>().add(UpdateQuestionEvent(
      questionId: widget.question.questionId,
      data: questionData,
      newOptions: newOptions,
      updatedOptions: updatedOptions,
      deletedOptionIds: _deletedOptionIds,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuestionBloc, QuestionState>(
      listener: (context, state) {
        if (state is QuestionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!), backgroundColor: Colors.green));
          Navigator.pop(context, true);
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
            title: const Text('Update Question', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
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
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: state.isLoading 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text('UPDATE QUESTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
    final label = String.fromCharCode(65 + index);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: index == _correctIndex ? primaryColor : const Color(0xFFF1F5F9), width: index == _correctIndex ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Radio<int>(
              value: index,
              groupValue: _correctIndex,
              activeColor: primaryColor,
              onChanged: (v) => setState(() => _correctIndex = v!),
            ),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: index == _correctIndex ? primaryColor : Colors.grey)),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _optionControllers[index],
                decoration: InputDecoration(hintText: 'Option $label', border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 8)),
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
            ),
            if (_optionControllers.length > 2)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => _removeOption(index),
              ),
          ],
        ),
      ),
    );
  }
}
