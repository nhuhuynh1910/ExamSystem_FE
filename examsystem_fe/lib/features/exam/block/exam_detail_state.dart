import '../models/exam_model.dart';

/// States cho ExamDetailCubit (GET /api/exams/{id}).
sealed class ExamDetailState {
  const ExamDetailState();
}

class ExamDetailInitial extends ExamDetailState {
  const ExamDetailInitial();
}

class ExamDetailLoading extends ExamDetailState {
  const ExamDetailLoading();
}

class ExamDetailLoaded extends ExamDetailState {
  final ExamModel exam;
  const ExamDetailLoaded({required this.exam});
}

class ExamDetailError extends ExamDetailState {
  final String message;
  const ExamDetailError({required this.message});
}
