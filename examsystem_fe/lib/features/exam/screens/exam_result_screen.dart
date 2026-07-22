import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../data/exam_repository.dart';
import '../models/attempt_details_response.dart';
import '../models/exam_submit_response.dart';
import '../models/question_model.dart';

class ExamResultScreen extends StatefulWidget {
  final int attemptId;
  final ExamSubmitResponse submitResponse;

  const ExamResultScreen({
    super.key,
    required this.attemptId,
    required this.submitResponse,
  });

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  final ExamRepository _repository = ExamRepository();
  AttemptDetailsResponse? _attemptDetails;
  bool _isLoading = true;
  String? _errorMessage;
  final Set<int> _expandedQuestionIds = {};

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  /// Lấy thông tin chi tiết bài làm để sinh viên xem lại câu hỏi (API GET /api/attempts/{id})
  Future<void> _fetchDetails() async {
    try {
      final details = await _repository.getAttemptDetails(widget.attemptId);
      setState(() {
        _attemptDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load review details. You can still see your score above.';
        _isLoading = false;
      });
    }
  }

  /// Thu gọn hoặc mở rộng câu hỏi khi xem lại danh sách đáp án
  void _toggleExpand(int questionId) {
    setState(() {
      if (_expandedQuestionIds.contains(questionId)) {
        _expandedQuestionIds.remove(questionId);
      } else {
        _expandedQuestionIds.add(questionId);
      }
    });
  }

  /// Kiểm tra xem câu hỏi hiện tại sinh viên chọn đúng hay sai
  /// Bằng cách so sánh tập hợp selectedOptionIds của sinh viên với đáp án đúng (isCorrect = true)
  bool _checkIsQuestionCorrect(QuestionModel question) {
    final correctOptionIds = question.options
        .where((o) => o.isCorrect)
        .map((o) => o.optionId)
        .toSet();
    final userSelectedSet = question.selectedOptionIds.toSet();
    
    if (correctOptionIds.isEmpty && userSelectedSet.isEmpty) {
      return false;
    }
    return correctOptionIds.length == userSelectedSet.length &&
        correctOptionIds.containsAll(userSelectedSet);
  }

  String _formatDuration(DateTime start, DateTime end) {
    final diff = end.difference(start);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }
    return '${minutes}m ${seconds}s';
  }

  String _formatAttempt(int num) {
    if (num == 1) return '1st';
    if (num == 2) return '2nd';
    if (num == 3) return '3rd';
    return '${num}th';
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.submitResponse;
    final isPassed = r.isPassed;
    final timeSpent = _formatDuration(r.startTime, r.submitTime);
    final attemptText = _formatAttempt(r.attemptNumber);

    // Calculate correct questions count
    int correctCount = 0;
    if (_attemptDetails != null) {
      for (var q in _attemptDetails!.questions) {
        if (_checkIsQuestionCorrect(q)) {
          correctCount++;
        }
      }
    } else {
      // Fallback estimate if details haven't loaded yet
      correctCount = (r.score / (r.totalScore > 0 ? r.totalScore : 10) * r.totalQuestions).round();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF15A22),
        elevation: 0.5,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go(AppRouter.studentDashboard);
            }
          },
        ),
        title: const Text(
          'Exam Result',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth >= 720;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? (constraints.maxWidth - 640) / 2 : 16.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Result Hero Card
                _buildHeroCard(isPassed, r.score, r.totalScore, correctCount, r.totalQuestions, timeSpent, attemptText),
                const SizedBox(height: 24),
                // Answer Review Section
                const Text(
                  'Answer Review',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3557),
                  ),
                ),
                const SizedBox(height: 12),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(color: Color(0xFFF15A22)),
                    ),
                  )
                else if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ..._attemptDetails!.questions.map((q) => _buildQuestionCard(q)),
                const SizedBox(height: 100), // Spacing for sticky bottom actions
              ],
            ),
          );
        },
      ),
      // Bottom Sticky Actions
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF15A22),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  context.go(AppRouter.studentDashboard);
                }
              },
              child: const Text(
                'Back to Exams',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(
    bool isPassed,
    double score,
    double totalScore,
    int correctCount,
    int totalQuestions,
    String timeSpent,
    String attemptText,
  ) {
    final double percentage = totalScore > 0 ? score / totalScore : 0.0;
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Donut Chart
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 10,
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isPassed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      score % 1 == 0 ? score.toInt().toString() : score.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isPassed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        height: 1.1,
                      ),
                    ),
                    Text(
                      '/${totalScore > 0 ? totalScore.toInt() : 10}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isPassed ? const Color(0xFFD1FAE5) : const Color(0xFFFFDAD6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPassed ? Icons.check_circle : Icons.cancel,
                  color: isPassed ? const Color(0xFF10B981) : const Color(0xFFBA1A1A),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isPassed ? 'PASSED' : 'FAILED',
                  style: TextStyle(
                    color: isPassed ? const Color(0xFF10B981) : const Color(0xFFBA1A1A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 20),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.track_changes, '$correctCount/$totalQuestions', 'Correct'),
              Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
              _buildStatItem(Icons.timer_outlined, timeSpent, 'Time'),
              Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
              _buildStatItem(Icons.restart_alt_outlined, attemptText, 'Attempt'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFF15A22), size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D3557),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(QuestionModel question) {
    final isExpanded = _expandedQuestionIds.contains(question.questionId);
    final isCorrect = _checkIsQuestionCorrect(question);
    
    // Find correct option text
    final correctOptions = question.options.where((o) => o.isCorrect).toList();
    final correctOptionText = correctOptions.isNotEmpty
        ? correctOptions.map((o) => o.optionText).join(', ')
        : 'No correct option designated';

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _toggleExpand(question.questionId),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Q${question.questionOrder} — ${question.content}',
                      maxLines: isExpanded ? 5 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1D3557),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isCorrect ? Icons.check_circle_outline : Icons.close,
                    color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Color(0xFFF1F5F9), height: 16),
                  // List all options
                  ...question.options.map((opt) {
                    final isUserSelected = question.selectedOptionIds.contains(opt.optionId);
                    final isCorrectOption = opt.isCorrect;
                    
                    Color optColor = Colors.white;
                    Color borderClr = const Color(0xFFE2E8F0);
                    Widget? trailingIcon;

                    if (isUserSelected) {
                      if (isCorrectOption) {
                        optColor = const Color(0xFFD1FAE5);
                        borderClr = const Color(0xFF10B981);
                        trailingIcon = const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16);
                      } else {
                        optColor = const Color(0xFFFFDAD6);
                        borderClr = const Color(0xFFBA1A1A);
                        trailingIcon = const Icon(Icons.cancel, color: Color(0xFFBA1A1A), size: 16);
                      }
                    } else if (isCorrectOption) {
                      borderClr = const Color(0xFF10B981);
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: optColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderClr, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isUserSelected ? (opt.isCorrect ? const Color(0xFF10B981) : const Color(0xFFBA1A1A)) : Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _getOptionLabel(opt.optionOrder),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isUserSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              opt.optionText,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF1D3557)),
                            ),
                          ),
                          trailingIcon ?? const SizedBox.shrink(),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  // Correct Answer explanation card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFAF8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF15A22).withAlpha(38)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Correct Answer:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF15A22),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          correctOptionText,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1D3557),
                          ),
                        ),
                        if (question.explanation.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            question.explanation,
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getOptionLabel(int order) {
    if (order == 1) return 'A';
    if (order == 2) return 'B';
    if (order == 3) return 'C';
    if (order == 4) return 'D';
    if (order == 5) return 'E';
    return '$order';
  }
}
