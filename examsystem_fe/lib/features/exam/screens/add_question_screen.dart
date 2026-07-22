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
  final List<int> existingQuestionIds; // Thêm trường này
  const AddQuestionScreen({
    super.key, 
    required this.examId, 
    required this.subjectId,
    this.existingQuestionIds = const [], // Mặc định rỗng
  });

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<int> _selectedIds = [];
  final Map<int, double> _questionScores = {};
  final Map<int, int> _orders = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedIds.addAll(widget.existingQuestionIds);
    
    // Gọi event tải ngân hàng câu hỏi để phân tách Đã chọn / Chưa chọn
    context.read<ExamBloc>().add(LoadBankQuestionsForExamEvent(
      examId: widget.examId,
      subjectId: widget.subjectId,
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Manage Questions', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFF97316),
          indicatorColor: const Color(0xFFF97316),
          tabs: const [
            Tab(text: 'AVAILABLE'),
            Tab(text: 'IN EXAM'),
          ],
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ExamBloc, ExamState>(
            listener: (context, state) {
              if (state is ExamOperationSuccess && state.message != null && state.message!.toLowerCase().contains('thêm câu hỏi')) {
                // Có thể không cần pop ngay để GV thêm tiếp
              }
            },
          ),
        ],
        child: BlocBuilder<ExamBloc, ExamState>(
          builder: (context, state) {
            if (state.isLoading && state.tempBankQuestions.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)));
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _buildQuestionList(state.unselectedQuestions, isAvailable: true),
                _buildQuestionList(state.selectedQuestions, isAvailable: false),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildQuestionList(List<dynamic> questions, {required bool isAvailable}) {
    if (questions.isEmpty) {
      return Center(child: Text(isAvailable ? 'No more questions available' : 'No questions in this exam yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
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
            onChanged: isAvailable ? (v) {
              setState(() {
                if (v!) {
                  _selectedIds.add(qItem.questionId);
                  _questionScores[qItem.questionId] = (qItem.score as num?)?.toDouble() ?? 0.0;
                } else {
                  _selectedIds.remove(qItem.questionId);
                }
              });
            } : null,
            title: Text(qItem.content ?? '', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            subtitle: Text('${qItem.difficulty} • ${qItem.score} pts'),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            if (_tabController.index == 0)
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final newSelection = _selectedIds.where((id) => !widget.existingQuestionIds.contains(id)).toList();
                  if (newSelection.isEmpty) {
                    Navigator.pop(context);
                    return;
                  }
                  for (var id in newSelection) {
                    final req = AddExamQuestionRequest(questionId: id, questionOrder: 0, score: _questionScores[id]);
                    context.read<ExamBloc>().add(AddQuestionToExamEvent(widget.examId, req));
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('ADD TO EXAM', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
