import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/exam_repository.dart';
import 'exam_list_state.dart';

/// Cubit tải danh sách đề thi - GET /api/exams.
class ExamListCubit extends Cubit<ExamListState> {
  final ExamRepository _repository;

  ExamListCubit({ExamRepository? repository})
    : _repository = repository ?? ExamRepository(),
      super(const ExamListInitial());

  Future<void> loadExams({int? subjectId, int pageNumber = 1, int pageSize = 10}) async {
    emit(const ExamListLoading());
    try {
      final result = await _repository.getExamsPaginated(
        subjectId: subjectId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      emit(ExamListLoaded(paginated: result));
    } catch (e) {
      emit(ExamListError(message: e.toString()));
    }
  }
}
