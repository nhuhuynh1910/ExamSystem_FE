import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../block/start_exam_cubit.dart';
import '../block/start_exam_state.dart';
import 'exam_taking_screen.dart';

class EnterAccessCodeScreen extends StatefulWidget {
  final int examId;
  final String examName;
  final int durationMinutes;
  final DateTime? endTime;

  const EnterAccessCodeScreen({
    super.key,
    required this.examId,
    required this.examName,
    this.durationMinutes = 60,
    this.endTime,
  });

  @override
  State<EnterAccessCodeScreen> createState() => _EnterAccessCodeScreenState();
}

class _EnterAccessCodeScreenState extends State<EnterAccessCodeScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StartExamCubit(),
      child: BlocConsumer<StartExamCubit, StartExamState>(
        listener: (context, state) {
          if (state is StartExamSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.startResponse.isResume
                      ? '🔄 Resuming previous attempt...'
                      : '✅ Exam started successfully!',
                ),
                backgroundColor: const Color(0xFF2E7D32),
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ExamTakingScreen(
                  attemptId: state.startResponse.attemptId,
                  durationMinutes: widget.durationMinutes,
                  questions: state.questions,
                  examName: widget.examName,
                  attemptStartTime: state.attemptStartTime,
                  examEndTime: widget.endTime,
                ),
              ),
            );
          }
          if (state is StartExamFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFBA1A1A),
              ),
            );
            context.read<StartExamCubit>().reset();
          }
        },
        builder: (context, state) {
          final loading = state is StartExamLoading;

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
                'Nhập mã truy cập',
                style: TextStyle(
                  color: Color(0xFFF15A22),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Security Icon Shield with Glow effect
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFF15A22).withAlpha(25),
                              ),
                            ),
                            Container(
                              width: 96,
                              height: 96,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF15A22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x33F15A22),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.lock_person_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Subheading
                        const Text(
                          'Yêu cầu mã truy cập',
                          style: TextStyle(
                            color: Color(0xFF0B1C30),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Instructions
                        const Text(
                          'Vui lòng nhập mã truy cập được cung cấp bởi giảng viên hoặc phòng đào tạo để bắt đầu bài thi này.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF5A4139),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Input Card Container
                        Container(
                          padding: const EdgeInsets.all(20),
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Access Code Label
                              const Text(
                                'MÃ TRUY CẬP',
                                style: TextStyle(
                                  color: Color(0xFF1D3557),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Text Field
                              TextFormField(
                                controller: _codeController,
                                autofocus: true,
                                textCapitalization:
                                    TextCapitalization.characters,
                                style: const TextStyle(
                                  color: Color(0xFF0B1C30),
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'EXAM-123-ABC',
                                  hintStyle: TextStyle(
                                    color: const Color(
                                      0xFF8E7067,
                                    ).withAlpha(150),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF1F5F9),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  suffixIcon: const Icon(
                                    Icons.vpn_key_outlined,
                                    color: Color(0xFF8E7067),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter the access code';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Confirm button
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF15A22),
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: loading
                                      ? null
                                      : () {
                                          if (_formKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            context
                                                .read<StartExamCubit>()
                                                .checkAndStartExam(
                                                  examId: widget.examId,
                                                  accessCode: _codeController
                                                      .text
                                                      .trim(),
                                                );
                                          }
                                        },
                                  child: loading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Confirm & Start Exam',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Helper Footer Link
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Gặp sự cố? ',
                                    style: TextStyle(
                                      color: Color(0xFF5A4139),
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Liên hệ bộ phận hỗ trợ',
                                    style: TextStyle(
                                      color: Color(0xFFF15A22),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Subtle branding
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF15A22),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'FPT UNIVERSITY EXAM SYSTEM',
                              style: TextStyle(
                                color: Color(0xFF485F84),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
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
          );
        },
      ),
    );
  }
}
