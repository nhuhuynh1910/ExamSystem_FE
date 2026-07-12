import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_constants.dart';
import '../bloc/exam_bloc.dart';
import '../bloc/exam_event.dart';
import '../bloc/exam_state.dart';
import '../../question/bloc/question_bloc.dart';
import '../../question/bloc/question_state.dart' as q;
import '../widgets/question_tile.dart';
import 'add_question_screen.dart';
import 'update_exam_screen.dart';

class ExamDetailScreen extends StatefulWidget {
  final int examId;
  const ExamDetailScreen({super.key, required this.examId});

  @override
  State<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends State<ExamDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDetail();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDetail() {
    context.read<ExamBloc>().add(LoadExamDetailEvent(widget.examId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExamBloc, ExamState>(
      builder: (context, state) {
        final exam = state.selectedExam;
        final questions = state.examQuestions ?? [];

        return Scaffold(
          backgroundColor: Colors.white,
          body: state.isLoading && exam == null
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)))
              : exam == null
                  ? _buildErrorState()
                  : _buildCustomBody(exam, questions),
          bottomNavigationBar: exam != null && exam.status == 'Draft' 
              ? _buildBottomAction(exam) 
              : null,
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Cannot load exam details'),
          TextButton(onPressed: _loadDetail, child: const Text('Try Again')),
        ],
      ),
    );
  }

  Widget _buildCustomBody(exam, List questions) {
    final String? imageUrl = exam.examImageUrl != null && exam.examImageUrl!.isNotEmpty
        ? (exam.examImageUrl!.startsWith('http') ? exam.examImageUrl : "${ApiConstants.baseUrl.replaceAll('/api', '')}${exam.examImageUrl}")
        : null;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          stretch: true,
          backgroundColor: const Color(0xFFF97316),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [StretchMode.zoomBackground],
            background: Stack(
              fit: StackFit.expand,
              children: [
                imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: const Color(0xFFF97316),
                          child: const Icon(Icons.assignment_rounded, size: 80, color: Colors.white),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFF97316),
                        child: const Icon(Icons.assignment_rounded, size: 80, color: Colors.white),
                      ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.black.withOpacity(0.7)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        (exam.subjectName ?? 'Unknown Subject').toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFFF97316)),
                      ),
                    ),
                    const Spacer(),
                    _buildStatusBadge(exam.status),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  exam.examName,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFFF97316),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFFF97316),
                indicatorWeight: 3,
                tabs: [
                  const Tab(text: 'OVERVIEW'),
                  Tab(text: 'QUESTIONS (${questions.length})'),
                ],
              ),
            ],
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(exam),
          _buildQuestionsTab(exam, questions),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(exam) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatBox(Icons.timer_outlined, 'Duration', '${exam.durationMinutes} mins'),
              const SizedBox(width: 12),
              _buildStatBox(Icons.event_available_outlined, 'End Time', _formatDate(exam.endTime)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatBox(Icons.grade_outlined, 'Passing', '${exam.passingScore} / ${exam.totalScore} pts'),
              const SizedBox(width: 12),
              _buildStatBox(Icons.refresh_rounded, 'Attempts', '${exam.maxAttempts} max'),
            ],
          ),
          const SizedBox(height: 32),
          const Text('DESCRIPTION', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF97316), letterSpacing: 1.2, fontSize: 12)),
          const SizedBox(height: 12),
          Text(
            exam.description ?? 'No description provided.',
            style: TextStyle(color: Colors.grey[700], height: 1.6, fontSize: 15),
          ),
          const SizedBox(height: 32),
          const Text('INSTRUCTIONS', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF97316), letterSpacing: 1.2, fontSize: 12)),
          const SizedBox(height: 16),
          _buildInstructionItem('Read each question carefully before selecting an answer.'),
          _buildInstructionItem('No tab switching allowed; your session will be locked.'),
          _buildInstructionItem('Auto-submit feature is enabled when the timer expires.'),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildQuestionsTab(exam, List questions) {
    if (questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No questions added yet', style: TextStyle(color: Colors.grey)),
            if (exam.status == 'Draft')
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddQuestionScreen(examId: exam.examId, subjectId: exam.subjectId)),
                  ).then((_) => _loadDetail()),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Questions'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316), foregroundColor: Colors.white),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: questions.length + (exam.status == 'Draft' ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == questions.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddQuestionScreen(examId: exam.examId, subjectId: exam.subjectId)),
              ).then((_) => _loadDetail()),
              icon: const Icon(Icons.add),
              label: const Text('ADD MORE QUESTIONS'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFF97316),
                side: const BorderSide(color: Color(0xFFF97316)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          );
        }
        return QuestionTile(
          question: questions[index],
          index: index + 1,
          onRemove: exam.status == 'Draft'
              ? () => context.read<ExamBloc>().add(RemoveQuestionFromExamEvent(exam.examId, questions[index].questionId))
              : null,
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'Published') color = Colors.green;
    if (status == 'Closed') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatBox(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: const Color(0xFFF97316)),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Color(0xFFF97316)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildBottomAction(exam) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _confirmPublish(exam.examId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('PUBLISH EXAM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF97316).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFFF97316)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UpdateExamScreen(exam: exam)),
                ).then((_) => _loadDetail()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPublish(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Publish Exam?'),
        content: const Text('Once published, students can start taking this exam. You can still manage questions until it\'s closed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              context.read<ExamBloc>().add(PublishExamEvent(id));
              Navigator.pop(ctx);
            },
            child: const Text('Publish', style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
