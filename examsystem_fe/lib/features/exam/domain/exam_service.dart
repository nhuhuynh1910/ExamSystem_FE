import '../data/exam_repository.dart';
import '../models/exam_model.dart';
import '../models/exam_question_model.dart';
import '../models/exam_create_request.dart';
import '../models/exam_update_request.dart';
import '../models/add_exam_question_request.dart';
import '../models/subject_model.dart';

class ExamService {
  final ExamRepository _repository;

  ExamService(this._repository);

  Future<List<SubjectModel>> getSubjects() => _repository.getSubjects();
  Future<List<SubjectModel>> getTeacherSubjects() => _repository.getTeacherSubjects();
  Future<List<SubjectModel>> getEnrolledSubjects(int studentId) => _repository.getEnrolledSubjects(studentId);

  Future<List<ExamModel>> getExams({int? subjectId, int pageNumber = 1, int pageSize = 10}) => 
      _repository.getExams(subjectId: subjectId, pageNumber: pageNumber, pageSize: pageSize);
  Future<ExamModel> getExamById(int id) => _repository.getExamById(id);
  Future<ExamModel> createExam(ExamCreateRequest req) => _repository.createExam(req);
  Future<ExamModel> updateExam(int id, ExamUpdateRequest req) => _repository.updateExam(id, req);
  Future<void> deleteExam(int id) => _repository.deleteExam(id);
  Future<ExamModel> restoreExam(int id) => _repository.restoreExam(id);
  Future<ExamModel> publishExam(int id) => _repository.publishExam(id);
  Future<ExamModel> closeExam(int id) => _repository.closeExam(id);

  Future<List<ExamQuestionModel>> getExamQuestions(int id) => _repository.getExamQuestions(id);
  Future<void> addQuestionToExam(int id, AddExamQuestionRequest req) => _repository.addQuestionToExam(id, req);
  Future<void> removeQuestionFromExam(int examId, int questionId) => _repository.removeQuestionFromExam(examId, questionId);

  Future<List<ExamModel>> getTeacherExams({String? status, int? subjectId, int pageNumber = 1, int pageSize = 10}) => 
      _repository.getTeacherExams(status: status, subjectId: subjectId, pageNumber: pageNumber, pageSize: pageSize);
}
