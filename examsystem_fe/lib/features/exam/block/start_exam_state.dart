import '../models/exam_start_response.dart';
import '../models/question_model.dart';

/// States cho StartExamCubit quản lý luồng: Check-Access -> Start -> Load Questions
sealed class StartExamState {
  const StartExamState();
}

class StartExamInitial extends StartExamState {
  const StartExamInitial();
}

class StartExamLoading extends StartExamState {
  final String statusMessage;
  const StartExamLoading({this.statusMessage = 'Đang xử lý...'});
}

class StartExamCodeRequired extends StartExamState {
  final String? errorMessage;
  const StartExamCodeRequired({this.errorMessage});
}

class StartExamSuccess extends StartExamState {
  final ExamStartResponse startResponse;
  final List<QuestionModel> questions;
  final DateTime attemptStartTime;

  const StartExamSuccess({
    required this.startResponse,
    required this.questions,
    required this.attemptStartTime,
  });
}

class StartExamFailure extends StartExamState {
  final String message;
  final int? statusCode;
  const StartExamFailure({required this.message, this.statusCode});
}
