import '../models/question_model.dart';
import '../../exam/models/subject_model.dart';

abstract class QuestionState {
  final List<QuestionModel>? questions;
  final List<SubjectModel>? subjects;
  final String? message;
  final String? error;
  final bool isLoading;

  const QuestionState({
    this.questions,
    this.subjects,
    this.message,
    this.error,
    this.isLoading = false,
  });
}

class QuestionInitial extends QuestionState {
  QuestionInitial() : super();
}

class QuestionLoading extends QuestionState {
  QuestionLoading({super.questions, super.subjects}) : super(isLoading: true);
}

class QuestionsLoaded extends QuestionState {
  const QuestionsLoaded(List<QuestionModel> questions, {List<SubjectModel>? subjects})
      : super(questions: questions, subjects: subjects);
}

class SubjectsLoaded extends QuestionState {
  const SubjectsLoaded(List<SubjectModel> subjects, {List<QuestionModel>? questions})
      : super(subjects: subjects, questions: questions);
}

class QuestionOperationSuccess extends QuestionState {
  const QuestionOperationSuccess(String message, {super.questions, super.subjects})
      : super(message: message);
}

class QuestionError extends QuestionState {
  const QuestionError(String error, {super.questions, super.subjects})
      : super(error: error);
}
