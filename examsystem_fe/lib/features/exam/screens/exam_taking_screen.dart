import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../block/exam_taking_cubit.dart';
import '../block/exam_taking_state.dart';
import '../models/question_model.dart';

class ExamTakingScreen extends StatefulWidget {
  final int attemptId;
  final int durationMinutes;
  final List<QuestionModel> questions;
  final String examName;
  final DateTime attemptStartTime;
  final DateTime? examEndTime;

  const ExamTakingScreen({
    super.key,
    required this.attemptId,
    required this.durationMinutes,
    required this.questions,
    required this.examName,
    required this.attemptStartTime,
    this.examEndTime,
  });

  @override
  State<ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen> with WidgetsBindingObserver {
  late PageController _pageController;
  Timer? _countdownTimer;
  late int _remainingSeconds;
  bool _allowPop = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();

    // Tính toán thời gian đếm ngược chính xác theo công thức của BE
    // attemptEndTime = attempt.startTime + durationMinutes
    final attemptEndTime = widget.attemptStartTime.add(Duration(minutes: widget.durationMinutes));

    // realEndTime = min(attemptEndTime, exam.endTime)
    final realEndTime = (widget.examEndTime != null && widget.examEndTime!.isBefore(attemptEndTime))
        ? widget.examEndTime!
        : attemptEndTime;

    // remaining = realEndTime - currentTime
    final now = DateTime.now();
    _remainingSeconds = realEndTime.difference(now).inSeconds;
    if (_remainingSeconds < 0) {
      _remainingSeconds = 0;
    }

    _startTimer();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _remainingSeconds = 0;
        _autoSubmit();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    String pad(int n) => n.toString().padLeft(2, '0');
    if (hours > 0) {
      return '${pad(hours)}:${pad(minutes)}:${pad(seconds)}';
    }
    return '${pad(minutes)}:${pad(seconds)}';
  }

  void _autoSubmit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⏳ Time is up! Automatically submitting your exam...'),
        backgroundColor: Colors.orange,
      ),
    );
    setState(() {
      _allowPop = true;
    });
    context.read<ExamTakingCubit>().submitExam(isAutoSubmitted: true);
  }

  void _autoSubmitOnExit() {
    if (_allowPop) return;

    setState(() {
      _allowPop = true;
    });

    context.read<ExamTakingCubit>().submitExam(isAutoSubmitted: true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚠️ You left the exam. System automatically submitted your exam!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _autoSubmitOnExit();
    }
  }

  void _confirmSubmit(BuildContext cubitContext) {
    final cubit = cubitContext.read<ExamTakingCubit>();
    showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Submit Exam'),
          content: const Text('Are you sure you want to submit the exam now?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF15A22),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() {
          _allowPop = true;
        });
        cubit.submitExam(isAutoSubmitted: false);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialAnswers = <int, List<int>>{};
    for (var question in widget.questions) {
      if (question.selectedOptionIds.isNotEmpty) {
        initialAnswers[question.questionId] = question.selectedOptionIds;
      } else {
        final selectedIds = question.options
            .where((opt) => opt.isSelected)
            .map((opt) => opt.optionId)
            .toList();
        if (selectedIds.isNotEmpty) {
          initialAnswers[question.questionId] = selectedIds;
        }
      }
    }

    return BlocProvider(
      create: (_) => ExamTakingCubit(
        attemptId: widget.attemptId,
        initialAnswers: initialAnswers,
      ),
      child: BlocConsumer<ExamTakingCubit, ExamTakingState>(
        listener: (context, state) {
          if (state is ExamTakingSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 Exam submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {
              _allowPop = true;
            });
            context.go('/exams');
          }
          if (state is ExamTakingFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ExamTakingSubmitting) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFFF15A22),
                    ),
                    SizedBox(height: 16),
                    Text('Submitting exam... Please do not close the app'),
                  ],
                ),
              ),
            );
          }

          final cubitState = state is ExamTakingInProgress
              ? state
              : ExamTakingInProgress(currentQuestionIndex: 0, answers: const {});

          final totalQuestions = widget.questions.length;
          final answeredQuestions = cubitState.answers.length;
          final progressRatio = totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;

          return PopScope(
            canPop: _allowPop,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;

              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text('⚠️ Exit Warning'),
                    content: const Text(
                      'If you exit, your exam will be AUTOMATICALLY SUBMITTED immediately. Are you sure you want to exit?'
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('Go Back to Exam', style: TextStyle(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('Exit & Submit', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                setState(() {
                  _allowPop = true;
                });
                if (context.mounted) {
                  context.read<ExamTakingCubit>().submitExam(isAutoSubmitted: true);
                }
              }
            },
            child: Scaffold(
              backgroundColor: const Color(0xFFFAFAFA),
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: AppBar(
                  backgroundColor: const Color(0xFFF15A22),
                  elevation: 3,
                  automaticallyImplyLeading: false,
                  flexibleSpace: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                  const Icon(Icons.description, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.examName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF15A22).withAlpha(51),
                                    blurRadius: 15,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.timer_outlined, color: Color(0xFFF15A22), size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatTime(_remainingSeconds),
                                    style: const TextStyle(
                                      color: Color(0xFFF15A22),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                // Warning if error occurs during auto-save
                if (cubitState.saveError != null)
                  Container(
                    width: double.infinity,
                    color: Colors.red.shade100,
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      cubitState.saveError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // PROGRESS BAR SECTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progress',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '$answeredQuestions / $totalQuestions answered',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progressRatio,
                          backgroundColor: const Color(0xFFE5E7EB),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF15A22)),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                // Question View (PageView)
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: totalQuestions,
                    onPageChanged: (index) {
                      context.read<ExamTakingCubit>().selectQuestion(index);
                    },
                    itemBuilder: (context, index) {
                      final question = widget.questions[index];
                      final selectedOptionIds = cubitState.answers[question.questionId] ?? [];

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // QUESTION CARD
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(13),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'QUESTION ${index + 1} OF $totalQuestions',
                                        style: const TextStyle(
                                          color: Color(0xFFF15A22),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.bookmark_border_rounded,
                                        color: Color(0xFF1D3557),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    question.content,
                                    style: const TextStyle(
                                      color: Color(0xFF1D3557),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ANSWER OPTIONS
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: question.options.asMap().entries.map((entry) {
                                  final optionIndex = entry.key;
                                  final option = entry.value;
                                  final isSelected = selectedOptionIds.contains(option.optionId);
                                  final letter = String.fromCharCode(65 + optionIndex);

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: Material(
                                      color: isSelected ? const Color(0xFFF15A22) : Colors.white,
                                      elevation: isSelected ? 4 : 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: isSelected ? const Color(0xFFF15A22) : const Color(0xFFE2E8F0),
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () {
                                          context.read<ExamTakingCubit>().selectOption(
                                            questionId: question.questionId,
                                            optionId: option.optionId,
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: isSelected ? Colors.white : const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  letter,
                                                  style: TextStyle(
                                                    color: isSelected ? const Color(0xFFF15A22) : const Color(0xFF1D3557),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Text(
                                                  option.optionText,
                                                  style: TextStyle(
                                                    color: isSelected ? Colors.white : const Color(0xFF1D3557),
                                                    fontSize: 15,
                                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              if (isSelected)
                                                const Icon(
                                                  Icons.check_circle_rounded,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            // NAVIGATION PREVIOUS / NEXT BUTTONS
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                                        side: const BorderSide(color: Color(0xFFF15A22), width: 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        foregroundColor: const Color(0xFFF15A22),
                                      ),
                                      onPressed: index > 0
                                          ? () {
                                              _pageController.previousPage(
                                                duration: const Duration(milliseconds: 300),
                                                curve: Curves.easeInOut,
                                              );
                                            }
                                          : null,
                                      icon: const Icon(Icons.arrow_back, size: 20),
                                      label: const Text(
                                        'Previous',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFF15A22),
                                        foregroundColor: Colors.white,
                                        elevation: 4,
                                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: index < totalQuestions - 1
                                          ? () {
                                              _pageController.nextPage(
                                                duration: const Duration(milliseconds: 300),
                                                curve: Curves.easeInOut,
                                              );
                                            }
                                          : null,
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Next',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward, size: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // QUESTION NAVIGATOR (GRID)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Question Navigator',
                                    style: TextStyle(
                                      color: Color(0xFF1D3557),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 44,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: totalQuestions,
                                      itemBuilder: (context, qIndex) {
                                        final question = widget.questions[qIndex];
                                        final hasAnswer = cubitState.answers.containsKey(question.questionId);
                                        final isCurrent = cubitState.currentQuestionIndex == qIndex;

                                        Color bgColor = const Color(0xFFE5E7EB);
                                        Color textColor = const Color(0xFF6B7280);
                                        BoxBorder? border;

                                        if (isCurrent) {
                                          bgColor = Colors.white;
                                          textColor = const Color(0xFFF15A22);
                                          border = Border.all(color: const Color(0xFFF15A22), width: 2);
                                        } else if (hasAnswer) {
                                          bgColor = const Color(0xFFF15A22);
                                          textColor = Colors.white;
                                        }

                                        return Container(
                                          margin: const EdgeInsets.only(right: 12.0),
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: bgColor,
                                            shape: BoxShape.circle,
                                            border: border,
                                          ),
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            onTap: () {
                                              _pageController.animateToPage(
                                                qIndex,
                                                duration: const Duration(milliseconds: 300),
                                                curve: Curves.easeInOut,
                                              );
                                            },
                                            child: Center(
                                              child: Text(
                                                '${qIndex + 1}',
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Safe space for the floating action button at the bottom
                            const SizedBox(height: 80),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: FloatingActionButton.extended(
                onPressed: () => _confirmSubmit(context),
                backgroundColor: const Color(0xFFF15A22),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                label: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Submit Exam',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          ),
        );
        },
      ),
    );
  }
}
