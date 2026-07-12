import '../models/exam_model.dart';
import '../models/exam_question_model.dart';
import '../models/subject_model.dart';

abstract class ExamState {
  final List<ExamModel>? exams;
  final List<SubjectModel>? subjects;
  final ExamModel? selectedExam;
  final List<ExamQuestionModel>? examQuestions;
  final String? message;
  final String? error;
  final bool isLoading;

  const ExamState({
    this.exams,
    this.subjects,
    this.selectedExam,
    this.examQuestions,
    this.message,
    this.error,
    this.isLoading = false,
  });
}

class ExamInitial extends ExamState {
  const ExamInitial() : super();
}

class ExamLoading extends ExamState {
  const ExamLoading({
    super.exams,
    super.subjects,
    super.selectedExam,
    super.examQuestions,
  }) : super(isLoading: true);
}

class ExamsLoaded extends ExamState {
  const ExamsLoaded(List<ExamModel> exams, {List<SubjectModel>? subjects})
      : super(exams: exams, subjects: subjects);
}

class SubjectsLoaded extends ExamState {
  const SubjectsLoaded(List<SubjectModel> subjects, {List<ExamModel>? exams})
      : super(subjects: subjects, exams: exams);
}

class ExamDetailLoaded extends ExamState {
  const ExamDetailLoaded(ExamModel exam, {List<ExamQuestionModel>? questions, List<SubjectModel>? subjects})
      : super(selectedExam: exam, examQuestions: questions, subjects: subjects);
}

class ExamQuestionsLoaded extends ExamState {
  const ExamQuestionsLoaded(List<ExamQuestionModel> questions)
      : super(examQuestions: questions);
}

class ExamOperationSuccess extends ExamState {
  const ExamOperationSuccess(String message, {
    super.exams,
    super.subjects,
    super.selectedExam,
    super.examQuestions,
  }) : super(message: message);
}

class ExamError extends ExamState {
  const ExamError(String error, {
    super.exams,
    super.subjects,
    super.selectedExam,
    super.examQuestions,
  }) : super(error: error);
}
