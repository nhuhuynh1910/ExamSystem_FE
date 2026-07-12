import '../models/exam_create_request.dart';
import '../models/exam_update_request.dart';
import '../models/add_exam_question_request.dart';

abstract class ExamEvent {
  const ExamEvent();
}

class LoadSubjectsEvent extends ExamEvent {
  const LoadSubjectsEvent();
}

class LoadExamsEvent extends ExamEvent {
  final int? subjectId;
  final int pageNumber;
  final int pageSize;
  const LoadExamsEvent({
    this.subjectId,
    this.pageNumber = 1,
    this.pageSize = 10,
  });
}

class LoadTeacherExamsEvent extends ExamEvent {
  final String? status;
  final int? subjectId;
  final int pageNumber;
  final int pageSize;
  const LoadTeacherExamsEvent({
    this.status,
    this.subjectId,
    this.pageNumber = 1,
    this.pageSize = 10,
  });
}

class LoadExamDetailEvent extends ExamEvent {
  final int examId;
  const LoadExamDetailEvent(this.examId);
}

class CreateExamEvent extends ExamEvent {
  final ExamCreateRequest request;
  const CreateExamEvent(this.request);
}

class UpdateExamEvent extends ExamEvent {
  final int examId;
  final ExamUpdateRequest request;
  const UpdateExamEvent(this.examId, this.request);
}

class DeleteExamEvent extends ExamEvent {
  final int examId;
  const DeleteExamEvent(this.examId);
}

class RestoreExamEvent extends ExamEvent {
  final int examId;
  const RestoreExamEvent(this.examId);
}

class PublishExamEvent extends ExamEvent {
  final int examId;
  const PublishExamEvent(this.examId);
}

class CloseExamEvent extends ExamEvent {
  final int examId;
  const CloseExamEvent(this.examId);
}

class LoadExamQuestionsEvent extends ExamEvent {
  final int examId;
  const LoadExamQuestionsEvent(this.examId);
}

class AddQuestionToExamEvent extends ExamEvent {
  final int examId;
  final AddExamQuestionRequest request;
  const AddQuestionToExamEvent(this.examId, this.request);
}

class RemoveQuestionFromExamEvent extends ExamEvent {
  final int examId;
  final int questionId;
  const RemoveQuestionFromExamEvent(this.examId, this.questionId);
}
