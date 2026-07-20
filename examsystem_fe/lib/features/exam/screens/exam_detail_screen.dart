import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/utils/token_storage.dart';
import '../bloc/exam_bloc.dart';
import '../bloc/exam_event.dart';
import '../bloc/exam_state.dart' hide ExamDetailLoaded;
import '../block/exam_detail_cubit.dart';
import '../block/exam_detail_state.dart';
import '../block/start_exam_cubit.dart';
import '../block/start_exam_state.dart';
import '../models/exam_model.dart';
import '../models/exam_question_model.dart';
import '../widgets/question_tile.dart';
import 'add_question_screen.dart';
import 'exam_taking_screen.dart';
import 'update_exam_screen.dart';

class ExamDetailScreen extends StatefulWidget {
  final int examId;
  const ExamDetailScreen({super.key, required this.examId});

  @override
  State<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends State<ExamDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkRoleAndLoad();
  }

  Future<void> _checkRoleAndLoad() async {
    final role = await TokenStorage.getRole();
    if (mounted) {
      setState(() {
        _userRole = role;
      });
      if (_isStudentRoute()) {
        try {
          context.read<ExamDetailCubit>().loadDetail(widget.examId);
        } catch (_) {}
      } else {
        context.read<ExamBloc>().add(LoadExamDetailEvent(widget.examId));
      }
    }
  }

  bool _isStudentRoute() {
    try {
      context.read<ExamDetailCubit>();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isStudentRoute()) {
      return BlocBuilder<ExamDetailCubit, ExamDetailState>(
        builder: (context, state) => switch (state) {
          ExamDetailInitial() => const _LoadingScaffold(),
          ExamDetailLoading() => const _LoadingScaffold(),
          ExamDetailError(:final message) => _ErrorScaffold(message: message),
          ExamDetailLoaded(:final exam, :final lastAttemptScore) => _DetailBody(
            exam: exam,
            lastAttemptScore: lastAttemptScore,
          ),
        },
      );
    } else {
      return BlocBuilder<ExamBloc, ExamState>(
        builder: (context, state) {
          final exam = state.selectedExam;
          final questions = state.examQuestions;

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
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Cannot load exam details'),
          TextButton(
            onPressed: () => context.read<ExamBloc>().add(LoadExamDetailEvent(widget.examId)),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBody(ExamModel exam, List<ExamQuestionModel> questions) {
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
                      colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent, Colors.black.withValues(alpha: 0.7)],
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
                        color: const Color(0xFFF97316).withValues(alpha: 0.1),
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

  Widget _buildOverviewTab(ExamModel exam) {
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
            exam.description.isNotEmpty ? exam.description : 'No description provided.',
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

  Widget _buildQuestionsTab(ExamModel exam, List<ExamQuestionModel> questions) {
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
                    MaterialPageRoute(builder: (_) => AddQuestionScreen(
                      examId: exam.examId, 
                      subjectId: exam.subjectId,
                      existingQuestionIds: questions.map((q) => q.questionId).toList().cast<int>(),
                    )),
                  ).then((_) => context.read<ExamBloc>().add(LoadExamDetailEvent(widget.examId))),
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
                MaterialPageRoute(builder: (_) => AddQuestionScreen(
                  examId: exam.examId, 
                  subjectId: exam.subjectId,
                  existingQuestionIds: questions.map((q) => q.questionId).toList().cast<int>(),
                )),
              ).then((_) => context.read<ExamBloc>().add(LoadExamDetailEvent(widget.examId))),
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
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
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

  Widget _buildBottomAction(ExamModel exam) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _confirmPublish(exam),
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
                color: const Color(0xFFF97316).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFFF97316)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UpdateExamScreen(exam: exam)),
                ).then((_) => context.read<ExamBloc>().add(LoadExamDetailEvent(widget.examId))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPublish(ExamModel exam) {
    final now = DateTime.now();
    if (exam.startTime != null && now.isAfter(exam.startTime!)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Cannot Publish'),
          content: const Text('The start time has already passed. Please update the exam schedule before publishing.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UpdateExamScreen(exam: exam)),
                ).then((_) => context.read<ExamBloc>().add(LoadExamDetailEvent(widget.examId)));
              },
              child: const Text('Update Schedule', style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold)),
            ),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Publish Exam?'),
        content: const Text('Once published, students can start taking this exam at the scheduled time.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              context.read<ExamBloc>().add(PublishExamEvent(exam.examId));
              Navigator.pop(ctx);
            },
            child: const Text('Publish', style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// ─── STUDENT PREVIEW WIDGETS (Cubit Flow) ────────────────────────────────────

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: Center(child: CircularProgressIndicator(color: Color(0xFFF15A22))),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  final String message;
  const _ErrorScaffold({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: BackButton(
          color: const Color(0xFFF15A22),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Error Loading Exam',
          style: TextStyle(
            color: Color(0xFF0B1C30),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Color(0xFFBA1A1A),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF485F84), fontSize: 15),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF15A22),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final ExamModel exam;
  final String lastAttemptScore;
  const _DetailBody({required this.exam, required this.lastAttemptScore});

  Widget _buildWebLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        exam.examImageUrl != null && exam.examImageUrl!.isNotEmpty
                            ? Image.network(
                                exam.examImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const _BannerFallback(),
                              )
                            : const _BannerFallback(),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withAlpha(178),
                                Colors.black.withAlpha(25),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD14307),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'ACADEMIC SESSION 2026',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                exam.examName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (exam.description.isNotEmpty) ...[
                  const Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: Color(0xFFF15A22),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Instructions',
                        style: TextStyle(
                          color: Color(0xFF0B1C30),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE2BFB4).withAlpha(127),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      exam.description,
                      style: const TextStyle(
                        color: Color(0xFF0B1C30),
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDAD6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFBA1A1A).withAlpha(38),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Color(0xFFBA1A1A),
                        size: 24,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Important Notice',
                              style: TextStyle(
                                color: Color(0xFF93000A),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Once you start, the timer cannot be paused. Ensure you have a stable internet connection and uninterrupted time.',
                              style: TextStyle(
                                color: Color(0xFF93000A),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 24, right: 24, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.gavel_rounded,
                      color: Color(0xFFF15A22),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Exam Information',
                      style: TextStyle(
                        color: Color(0xFF0B1C30),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  children: [
                    _BentoCard(
                      icon: Icons.schedule_outlined,
                      title: 'Duration',
                      value: '${exam.durationMinutes} Mins',
                    ),
                    _BentoCard(
                      icon: Icons.quiz_outlined,
                      title: 'Total Score',
                      value: '${exam.totalScore} Pts',
                    ),
                    _BentoCard(
                      icon: Icons.grade_outlined,
                      title: 'Passing Score',
                      value: '${exam.passingScore} Pts',
                    ),
                    _BentoCard(
                      icon: Icons.replay_outlined,
                      title: 'Max Attempts',
                      value: '${exam.maxAttempts} Times',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDCE9FF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Status',
                        style: TextStyle(
                          color: Color(0xFF0B1C30),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _StatusRow(
                        label: 'Allowed Attempts',
                        value: '${exam.maxAttempts}',
                      ),
                      const Divider(color: Color(0xFFDCE9FF), height: 24),
                      _StatusRow(
                        label: 'Last Attempt Score',
                        value: lastAttemptScore,
                      ),
                      const Divider(color: Color(0xFFDCE9FF), height: 24),
                      _StatusRow(
                        label: 'Access Status',
                        valueWidget: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              exam.isPrivate
                                  ? Icons.lock_outline
                                  : Icons.verified_user_outlined,
                              size: 16,
                              color: exam.isPrivate
                                  ? const Color(0xFFD14307)
                                  : const Color(0xFF2E7D32),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              exam.isPrivate ? 'Private' : 'Verified',
                              style: TextStyle(
                                color: exam.isPrivate
                                    ? const Color(0xFFD14307)
                                    : const Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withAlpha(51)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      BlocProvider(
                        create: (_) => StartExamCubit(),
                        child: _JoinButton(exam: exam),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'By clicking, you agree to the Academic Integrity Policy',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF485F84),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      exam.examImageUrl != null && exam.examImageUrl!.isNotEmpty
                          ? Image.network(
                              exam.examImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const _BannerFallback(),
                            )
                          : const _BannerFallback(),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withAlpha(178),
                              Colors.black.withAlpha(25),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD14307),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'ACADEMIC SESSION 2026',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              exam.examName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                children: [
                  _BentoCard(
                    icon: Icons.schedule_outlined,
                    title: 'Duration',
                    value: '${exam.durationMinutes} Mins',
                  ),
                  _BentoCard(
                    icon: Icons.quiz_outlined,
                    title: 'Total Score',
                    value: '${exam.totalScore} Pts',
                  ),
                  _BentoCard(
                    icon: Icons.grade_outlined,
                    title: 'Passing Score',
                    value: '${exam.passingScore} Pts',
                  ),
                  _BentoCard(
                    icon: Icons.replay_outlined,
                    title: 'Max Attempts',
                    value: '${exam.maxAttempts} Times',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDCE9FF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Status',
                      style: TextStyle(
                        color: Color(0xFF0B1C30),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _StatusRow(
                      label: 'Allowed Attempts',
                      value: '${exam.maxAttempts}',
                    ),
                    const Divider(color: Color(0xFFDCE9FF), height: 20),
                    _StatusRow(
                      label: 'Last Attempt Score',
                      value: lastAttemptScore,
                    ),
                    const Divider(color: Color(0xFFDCE9FF), height: 20),
                    _StatusRow(
                      label: 'Access Status',
                      valueWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            exam.isPrivate
                                ? Icons.lock_outline
                                : Icons.verified_user_outlined,
                            size: 16,
                            color: exam.isPrivate
                                ? const Color(0xFFD14307)
                                : const Color(0xFF2E7D32),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            exam.isPrivate ? 'Private' : 'Verified',
                            style: TextStyle(
                              color: exam.isPrivate
                                  ? const Color(0xFFD14307)
                                  : const Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (exam.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2BFB4).withAlpha(127),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            color: Color(0xFFF15A22),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Instructions',
                            style: TextStyle(
                              color: Color(0xFF0B1C30),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exam.description,
                        style: const TextStyle(
                          color: Color(0xFF0B1C30),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDAD6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFBA1A1A).withAlpha(38),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: Color(0xFFBA1A1A),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Once you start, the timer cannot be paused. Ensure you have a stable internet connection and uninterrupted time.',
                            style: TextStyle(
                              color: Color(0xFF93000A),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.withAlpha(51), width: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocProvider(
                    create: (_) => StartExamCubit(),
                    child: _JoinButton(exam: exam),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'By clicking, you agree to the Academic Integrity Policy',
                    style: TextStyle(
                      color: Color(0xFF485F84),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF15A22)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Exam Preview',
          style: TextStyle(
            color: Color(0xFFF15A22),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 850) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: _buildWebLayout(context),
              ),
            );
          } else {
            return _buildMobileLayout(context);
          }
        },
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _BentoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2BFB4).withAlpha(102)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF485F84)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF485F84),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF0B1C30),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _StatusRow({required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF485F84), fontSize: 14),
        ),
        if (valueWidget != null)
          valueWidget!
        else
          Text(
            value ?? '',
            style: const TextStyle(
              color: Color(0xFF0B1C30),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
      ],
    );
  }
}

class _BannerFallback extends StatelessWidget {
  const _BannerFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF15A22), Color(0xFFD14307)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _JoinButton extends StatelessWidget {
  final ExamModel exam;
  const _JoinButton({required this.exam});

  void _showAccessCodeDialog(BuildContext parentContext, String? errorMessage) {
    final codeController = TextEditingController();
    showDialog<void>(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.lock_outline_rounded, color: Color(0xFFF15A22)),
              const SizedBox(width: 8),
              const Text(
                'Access Code Required',
                style: TextStyle(
                  color: Color(0xFF0B1C30),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please enter the access code provided by your teacher to start the exam.',
                style: TextStyle(color: Color(0xFF485F84), fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                autofocus: true,
                style: const TextStyle(color: Color(0xFF0B1C30)),
                decoration: InputDecoration(
                  labelText: 'Access Code',
                  labelStyle: const TextStyle(color: Color(0xFF485F84)),
                  errorText: errorMessage,
                  filled: true,
                  fillColor: const Color(0xFFFAFAFA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                parentContext.read<StartExamCubit>().reset();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF485F84),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF15A22),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final code = codeController.text.trim();
                if (code.isEmpty) return;
                Navigator.of(dialogContext).pop();
                parentContext.read<StartExamCubit>().checkAndStartExam(
                  examId: exam.examId,
                  accessCode: code,
                );
              },
              child: const Text('Submit & Start'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StartExamCubit, StartExamState>(
      listener: (context, state) {
        if (state is StartExamSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ExamTakingScreen(
                attemptId: state.startResponse.attemptId,
                durationMinutes: exam.durationMinutes,
                questions: state.questions,
                examName: exam.examName,
                attemptStartTime: state.attemptStartTime,
                examEndTime: exam.endTime,
              ),
            ),
          );
        } else if (state is StartExamCodeRequired) {
          _showAccessCodeDialog(context, state.errorMessage);
        } else if (state is StartExamFailure) {
          if (state.message.toLowerCase().contains('code')) {
            _showAccessCodeDialog(context, state.message);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFBA1A1A),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        final loading = state is StartExamLoading;
        String statusMsg = 'Connecting...';
        if (state is StartExamLoading) {
          statusMsg = state.statusMessage;
        }

        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF15A22),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            onPressed: loading
                ? null
                : () {
                    context.read<StartExamCubit>().checkAndStartExam(
                      examId: exam.examId,
                      accessCode: null,
                    );
                  },
            child: loading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        statusMsg,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Start Exam',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.play_arrow, size: 20),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
