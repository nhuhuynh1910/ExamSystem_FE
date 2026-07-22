import '../models/paginated_exams.dart';

/// States cho ExamListCubit (GET /api/exams).
sealed class ExamListState {
  const ExamListState();
}

class ExamListInitial extends ExamListState {
  const ExamListInitial();
}

class ExamListLoading extends ExamListState {
  const ExamListLoading();
}

class ExamListLoaded extends ExamListState {
  final PaginatedExams paginated;
  const ExamListLoaded({required this.paginated});
}

class ExamListError extends ExamListState {
  final String message;
  const ExamListError({required this.message});
}
