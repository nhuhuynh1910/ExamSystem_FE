import 'package:dio/dio.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/check_access_request.dart';
import '../models/check_access_response.dart';
import '../models/exam_model.dart';
import '../models/exam_start_response.dart';
import '../models/paginated_exams.dart';
import '../models/question_model.dart';
import '../models/attempt_details_response.dart';
import '../models/exam_submit_response.dart';

// Import thêm từ nhánh Huỳnh
import 'exam_api.dart';
import '../models/exam_question_model.dart';
import '../models/exam_create_request.dart';
import '../models/exam_update_request.dart';
import '../models/add_exam_question_request.dart';
import '../models/subject_model.dart';

/// Repository cho toàn bộ Exam feature.
/// Kết hợp cả chức năng của Student (Thang/Trúc) và Teacher (Huỳnh).
class ExamRepository {
  final Dio _dio = DioClient.instance;
  final ExamApi _examApi = ExamApi(); // Từ nhánh Huỳnh

  // ════════════════════════════════════════════════════════════════════════════
  // ── PHẦN CỦA STUDENT (Thang & Trúc) ──────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════

  // ── GET /api/exams ──────────────────────────────────────────────────────────
  /// Lấy danh sách đề thi có phân trang, lọc theo môn học.
  Future<PaginatedExams> getExamsPaginated({
    int? subjectId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get(
      ApiConstants.exams,
      queryParameters: {
        if (subjectId != null) 'SubjectId': subjectId,
        'PageNumber': pageNumber,
        'PageSize': pageSize,
      },
    );
    return PaginatedExams.fromJson(response.data as Map<String, dynamic>);
  }

  // ── GET /api/exams/{id} ─────────────────────────────────────────────────────
  /// Lấy chi tiết một đề thi theo ID. (Dùng chung cho cả Student và Teacher)
  Future<ExamModel> getExamById(int examId) async {
    final response = await _dio.get(ApiConstants.examById(examId));
    return ExamModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── POST /api/exams/{examId}/check-access ───────────────────────────────────
  Future<CheckAccessResponse> checkAccess({
    required int examId,
    String? accessCode,
  }) async {
    final request = CheckAccessRequest(accessCode: accessCode);
    final response = await _dio.post(
      ApiConstants.examCheckAccess(examId),
      data: request.toJson(),
    );
    return CheckAccessResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // ── POST /api/exams/{examId}/start ──────────────────────────────────────────
  Future<ExamStartResponse> startExam({
    required int examId,
    String? accessCode,
  }) async {
    final response = await _dio.post(
      ApiConstants.examStart(examId),
      data: {'accessCode': accessCode},
    );
    return ExamStartResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // ── GET /api/exams/{examId}/questions ───────────────────────────────────────
  Future<List<QuestionModel>> getExamQuestionsStudent(int examId) async {
    final response = await _dio.get(ApiConstants.examQuestions(examId));
    final rawList = response.data as List<dynamic>? ?? [];
    return rawList
        .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── GET /api/attempts/{attemptId} ───────────────────────────────────────────
  Future<AttemptDetailsResponse> getAttemptDetails(int attemptId) async {
    final response = await _dio.get(ApiConstants.attemptDetails(attemptId));
    return AttemptDetailsResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── POST /api/attempts/{attemptId}/answers ──────────────────────────────────
  Future<void> saveAnswer({
    required int attemptId,
    required int questionId,
    required List<int> selectedOptionIds,
  }) async {
    await _dio.post(
      ApiConstants.attemptAnswers(attemptId),
      data: {'questionId': questionId, 'selectedOptionIds': selectedOptionIds},
    );
  }

  // ── POST /api/attempts/{attemptId}/submit ───────────────────────────────────
  Future<ExamSubmitResponse> submitAttempt({
    required int attemptId,
    required bool isAutoSubmitted,
  }) async {
    final response = await _dio.post(
      ApiConstants.attemptSubmit(attemptId),
      data: {'isAutoSubmitted': isAutoSubmitted},
    );
    return ExamSubmitResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // ── GET /api/exams/{examId}/result ─────────────────────────────────────────
  Future<dynamic> getExamResult(int examId) async {
    final response = await _dio.get(ApiConstants.examResult(examId));
    return response.data;
  }


  // ════════════════════════════════════════════════════════════════════════════
  // ── PHẦN CỦA TEACHER (Huỳnh) ────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════

  Future<List<SubjectModel>> getSubjects() => _examApi.getSubjects();
  Future<List<SubjectModel>> getTeacherSubjects() => _examApi.getTeacherSubjects();
  Future<List<SubjectModel>> getEnrolledSubjects(int studentId) => _examApi.getEnrolledSubjects(studentId);

  Future<List<ExamModel>> getExams({int? subjectId, int pageNumber = 1, int pageSize = 10}) => 
      _examApi.getExams(subjectId: subjectId, pageNumber: pageNumber, pageSize: pageSize);

  Future<ExamModel> createExam(ExamCreateRequest req) => _examApi.createExam(req);
  Future<ExamModel> updateExam(int id, ExamUpdateRequest req) => _examApi.updateExam(id, req);
  Future<void> deleteExam(int id) => _examApi.deleteExam(id);
  Future<ExamModel> restoreExam(int id) => _examApi.restoreExam(id);
  Future<ExamModel> publishExam(int id) => _examApi.publishExam(id);
  Future<ExamModel> closeExam(int id) => _examApi.closeExam(id);

  Future<List<ExamQuestionModel>> getExamQuestions(int id) => _examApi.getExamQuestions(id);
  Future<void> addQuestionToExam(int id, AddExamQuestionRequest req) => _examApi.addQuestion(id, req);
  Future<void> removeQuestionFromExam(int examId, int questionId) => _examApi.removeQuestion(examId, questionId);

  Future<List<ExamModel>> getTeacherExams({String? status, int? subjectId, int pageNumber = 1, int pageSize = 10}) => 
      _examApi.getTeacherExams(status: status, subjectId: subjectId, pageNumber: pageNumber, pageSize: pageSize);
}
