import 'exam_api.dart';
import '../models/exam_model.dart';
import '../models/exam_question_model.dart';
import '../models/exam_create_request.dart';
import '../models/exam_update_request.dart';
import '../models/add_exam_question_request.dart';
import '../models/subject_model.dart';

class ExamRepository {
  final ExamApi _examApi = ExamApi();

  Future<List<SubjectModel>> getSubjects() => _examApi.getSubjects();
  Future<List<SubjectModel>> getTeacherSubjects() => _examApi.getTeacherSubjects();

  Future<List<SubjectModel>> getEnrolledSubjects(int studentId) => _examApi.getEnrolledSubjects(studentId);

  Future<List<ExamModel>> getExams({int? subjectId, int pageNumber = 1, int pageSize = 10}) => 
      _examApi.getExams(subjectId: subjectId, pageNumber: pageNumber, pageSize: pageSize);
  Future<ExamModel> getExamById(int id) => _examApi.getExamById(id);
  Future<ExamModel> createExam(ExamCreateRequest req) => _examApi.createExam(req);
  Future<ExamModel> updateExam(int id, ExamUpdateRequest req) => _examApi.updateExam(id, req);
  Future<void> deleteExam(int id) => _examApi.deleteExam(id);
  Future<void> restoreExam(int id) => _examApi.restoreExam(id);
  Future<void> publishExam(int id) => _examApi.publishExam(id);
  Future<void> closeExam(int id) => _examApi.closeExam(id);

  Future<List<ExamQuestionModel>> getExamQuestions(int id) => _examApi.getExamQuestions(id);
  Future<void> addQuestionToExam(int id, AddExamQuestionRequest req) => _examApi.addQuestion(id, req);
  Future<void> removeQuestionFromExam(int examId, int questionId) => _examApi.removeQuestion(examId, questionId);

  Future<List<ExamModel>> getTeacherExams({String? status, int? subjectId, int pageNumber = 1, int pageSize = 10}) => 
      _examApi.getTeacherExams(status: status, subjectId: subjectId, pageNumber: pageNumber, pageSize: pageSize);
}
