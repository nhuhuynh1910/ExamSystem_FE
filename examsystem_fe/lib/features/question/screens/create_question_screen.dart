import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/question_bloc.dart';
import '../bloc/question_event.dart';
import '../bloc/question_state.dart';

class CreateQuestionScreen extends StatefulWidget {
  const CreateQuestionScreen({super.key});

  @override
  State<CreateQuestionScreen> createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _scoreController = TextEditingController(text: '1.0');
  final _explanationController = TextEditingController();
  int? _subjectId;
  String _difficulty = 'Easy';
  
  final List<Map<String, dynamic>> _options = [
    {'text': '', 'isCorrect': true, 'order': 1},
    {'text': '', 'isCorrect': false, 'order': 2},
  ];

  @override
  void initState() {
    super.initState();
    context.read<QuestionBloc>().add(LoadSubjectsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo Câu hỏi mới')),
      body: BlocConsumer<QuestionBloc, QuestionState>(
        listener: (context, state) {
          if (state is QuestionOperationSuccess) {
            Navigator.pop(context);
          }
          if (state is QuestionError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
          }
        },
        builder: (context, state) {
          final subjects = state.subjects ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<int>(
                    value: _subjectId,
                    decoration: const InputDecoration(labelText: 'Môn học', border: OutlineInputBorder()),
                    items: subjects.map((s) => DropdownMenuItem(
                      value: s.subjectId,
                      child: Text(s.subjectName),
                    )).toList(),
                    onChanged: (v) => setState(() => _subjectId = v),
                    validator: (v) => v == null ? 'Vui lòng chọn môn học' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(labelText: 'Nội dung câu hỏi', border: OutlineInputBorder()),
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Vui lòng nhập nội dung' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _difficulty,
                          decoration: const InputDecoration(labelText: 'Độ khó', border: OutlineInputBorder()),
                          items: ['Easy', 'Medium', 'Hard'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => _difficulty = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _scoreController,
                          decoration: const InputDecoration(labelText: 'Điểm mặc định', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Các phương án trả lời:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ..._options.asMap().entries.map((entry) {
                    int idx = entry.key;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _options[idx]['isCorrect'],
                            onChanged: (v) => setState(() {
                              for (var opt in _options) { opt['isCorrect'] = false; }
                              _options[idx]['isCorrect'] = v;
                            }),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(labelText: 'Phương án ${idx + 1}'),
                              onChanged: (v) => _options[idx]['text'] = v,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () => setState(() => _options.removeAt(idx)),
                          ),
                        ],
                      ),
                    );
                  }),
                  TextButton.icon(
                    onPressed: () => setState(() => _options.add({'text': '', 'isCorrect': false, 'order': _options.length + 1})),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm phương án'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _explanationController,
                    decoration: const InputDecoration(labelText: 'Giải thích (không bắt buộc)', border: OutlineInputBorder()),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                      child: state.isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('LƯU CÂU HỎI'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (!_options.any((opt) => opt['isCorrect'])) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ít nhất một đáp án đúng')));
        return;
      }
      if (_options.any((opt) => opt['text'].isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập nội dung cho tất cả các phương án')));
        return;
      }

      final data = {
        'SubjectId': _subjectId,
        'Content': _contentController.text,
        'QuestionType': 'MultipleChoice',
        'Difficulty': _difficulty,
        'Score': double.tryParse(_scoreController.text) ?? 1.0,
        'Explanation': _explanationController.text,
      };

      final optionsData = _options.map((opt) => {
        'OptionText': opt['text'],
        'IsCorrect': opt['isCorrect'],
        'OptionOrder': opt['order'],
      }).toList();

      context.read<QuestionBloc>().add(CreateQuestionEvent(data, optionsData));
    }
  }
}
