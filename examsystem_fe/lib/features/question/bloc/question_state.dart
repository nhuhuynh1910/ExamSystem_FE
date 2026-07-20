import '../models/question_model.dart';
import '../../exam/models/subject_model.dart';

abstract class QuestionState {
  final List<QuestionModel>? questions;
  final List<SubjectModel>? subjects;
  final String? message;
  final bool isLoading;

  const QuestionState({
    this.questions,
    this.subjects,
    this.message,
    this.isLoading = false,
  });
}

class QuestionInitial extends QuestionState {
  const QuestionInitial();
}

class QuestionLoading extends QuestionState {
  const QuestionLoading({
    super.questions,
    super.subjects,
  }) : super(isLoading: true);
}

class QuestionsLoaded extends QuestionState {
  const QuestionsLoaded({
    required List<QuestionModel> questions,
    List<SubjectModel>? subjects,
  }) : super(
    questions: questions,
    subjects: subjects,
  );
}

class SubjectsLoaded extends QuestionState {
  const SubjectsLoaded({
    required List<SubjectModel> subjects,
    List<QuestionModel>? questions,
  }) : super(
    subjects: subjects,
    questions: questions,
  );
}

class QuestionSuccess extends QuestionState {
  const QuestionSuccess(
      String message, {
        super.questions,
        super.subjects,
      }) : super(message: message);
}
class QuestionError extends QuestionState {

  final String error;

  const QuestionError(
      this.error, {
        super.questions,
        super.subjects,
      }) : super(message: error);

}