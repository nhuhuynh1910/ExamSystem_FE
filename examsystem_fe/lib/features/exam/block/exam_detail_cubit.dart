import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/exam_repository.dart';
import 'exam_detail_state.dart';

/// Cubit tải chi tiết đề thi - GET /api/exams/{id}.
class ExamDetailCubit extends Cubit<ExamDetailState> {
  final ExamRepository _repository;

  ExamDetailCubit({ExamRepository? repository})
    : _repository = repository ?? ExamRepository(),
      super(const ExamDetailInitial());

  Future<void> loadDetail(int examId) async {
    emit(const ExamDetailLoading());
    try {
      final exam = await _repository.getExamById(examId);
      
      String lastAttemptScore = 'N/A';
      try {
        final result = await _repository.getExamResult(examId);
        if (result is Map) {
          final score = result['score'];
          final totalScore = result['totalScore'];
          if (score != null && totalScore != null) {
            lastAttemptScore = '$score / $totalScore';
          }
        }
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) {
          // Ignore non-404 errors so the screen can still load with 'N/A'
        }
      } catch (_) {}

      emit(ExamDetailLoaded(exam: exam, lastAttemptScore: lastAttemptScore));
    } catch (e) {
      emit(ExamDetailError(message: e.toString()));
    }
  }
}
