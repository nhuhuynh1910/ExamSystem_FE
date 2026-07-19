import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../data/exam_repository.dart';
import 'exam_taking_state.dart';

class ExamTakingCubit extends Cubit<ExamTakingState> {
  final ExamRepository _repository;
  final int attemptId;

  ExamTakingCubit({
    required this.attemptId,
    Map<int, List<int>> initialAnswers = const {},
    ExamRepository? repository,
  }) : _repository = repository ?? ExamRepository(),
       super(
         ExamTakingInProgress(currentQuestionIndex: 0, answers: initialAnswers),
       );

  void selectQuestion(int index) {
    final currentState = state;
    if (currentState is ExamTakingInProgress) {
      emit(currentState.copyWith(currentQuestionIndex: index));
    }
  }

  Future<void> selectOption({
    required int questionId,
    required int optionId,
  }) async {
    final currentState = state;
    if (currentState is! ExamTakingInProgress) return;

    // Cập nhật câu trả lời cục bộ ngay lập tức để UI mượt mà (single choice)
    final updatedAnswers = Map<int, List<int>>.from(currentState.answers);
    updatedAnswers[questionId] = [optionId];

    emit(
      currentState.copyWith(
        answers: updatedAnswers,
        isSaving: true,
        saveError: null,
      ),
    );

    // Gọi API lưu câu trả lời ngầm lên Server
    try {
      await _repository.saveAnswer(
        attemptId: attemptId,
        questionId: questionId,
        selectedOptionIds: [optionId],
      );
      emit((state as ExamTakingInProgress).copyWith(isSaving: false));
    } on DioException catch (e) {
      emit(
        (state as ExamTakingInProgress).copyWith(
          isSaving: false,
          saveError: 'Failed to save answer: ${e.message}',
        ),
      );
    } catch (e) {
      emit(
        (state as ExamTakingInProgress).copyWith(
          isSaving: false,
          saveError: 'Error saving answer: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> submitExam({bool isAutoSubmitted = false}) async {
    emit(const ExamTakingSubmitting());
    try {
      final response = await _repository.submitAttempt(
        attemptId: attemptId,
        isAutoSubmitted: isAutoSubmitted,
      );
      emit(ExamTakingSubmitted(response));
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final msg = switch (code) {
        400 => 'Invalid submission data.',
        401 => 'Session expired.',
        403 => 'Permission denied or exam time has passed.',
        404 => 'Exam attempt not found.',
        _ => e.message ?? 'An error occurred while submitting the exam.',
      };
      emit(ExamTakingFailure(msg));
    } catch (e) {
      emit(ExamTakingFailure(e.toString()));
    }
  }
}
