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
      emit(ExamDetailLoaded(exam: exam));
    } catch (e) {
      emit(ExamDetailError(message: e.toString()));
    }
  }
}
