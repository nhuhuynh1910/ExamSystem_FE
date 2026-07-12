import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../question/bloc/question_bloc.dart';
import '../../question/bloc/question_event.dart';
import '../../question/bloc/question_state.dart' as q;
import '../bloc/exam_bloc.dart';
import '../bloc/exam_event.dart';
import '../bloc/exam_state.dart';
import '../models/add_exam_question_request.dart';

class AddQuestionScreen extends StatefulWidget {
  final int examId;
  final int subjectId;
  const AddQuestionScreen({super.key, required this.examId, required this.subjectId});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final List<int> _selectedIds = [];
  final Map<int, double> _scores = {};
  final Map<int, int> _orders = {};

  @override
  void initState() {
    super.initState();
    context.read<QuestionBloc>().add(LoadQuestionsEvent(
      queryParameters: {'SubjectId': widget.subjectId, 'Status': 'Published'}
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Questions', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ExamBloc, ExamState>(
            listener: (context, state) {
              if (state is ExamOperationSuccess && state.message != null && state.message!.toLowerCase().contains('thêm câu hỏi')) {
                Navigator.pop(context);
              }
            },
          ),
        ],
        child: BlocBuilder<QuestionBloc, q.QuestionState>(
          builder: (context, state) {
            final questions = state.questions ?? [];
            
            if (state.isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)));

            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final qItem = questions[index];
                      final isSelected = _selectedIds.contains(qItem.questionId);
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: isSelected ? const Color(0xFFF97316) : Colors.grey[200]!, width: isSelected ? 2 : 1),
                        ),
                        child: CheckboxListTile(
                          value: isSelected,
                          activeColor: const Color(0xFFF97316),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          onChanged: (v) {
                            setState(() {
                              if (v!) {
                                _selectedIds.add(qItem.questionId);
                                _scores[qItem.questionId] = qItem.score;
                                _orders[qItem.questionId] = _selectedIds.length;
                              } else {
                                _selectedIds.remove(qItem.questionId);
                              }
                            });
                          },
                          title: Text(qItem.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                _badge(qItem.difficulty, Colors.blue),
                                const SizedBox(width: 8),
                                _badge('${qItem.score} pts', Colors.orange),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _selectedIds.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  Widget _buildHeader() {
    double totalScore = 0;
    for (var id in _selectedIds) { totalScore += _scores[id] ?? 0; }
    
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.grey[50],
      child: Row(
        children: [
          _stat('Selected', '${_selectedIds.length}'),
          const SizedBox(width: 24),
          _stat('Total Score', '$totalScore'),
          const Spacer(),
          IconButton(icon: const Icon(Icons.search, color: Color(0xFFF97316)), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list_rounded, color: Color(0xFFF97316)), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _stat(l, v) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(color: Colors.grey, fontSize: 11)), Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]);

  Widget _badge(t, c) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(t, style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.bold)));

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () {
            for (var id in _selectedIds) {
              final req = AddExamQuestionRequest(questionId: id, questionOrder: _orders[id], score: _scores[id]);
              context.read<ExamBloc>().add(AddQuestionToExamEvent(widget.examId, req));
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF97316),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: BlocBuilder<ExamBloc, ExamState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                );
              }
              return const Text('ADD SELECTED QUESTIONS', style: TextStyle(fontWeight: FontWeight.bold));
            },
          ),
        ),
      ),
    );
  }
}
