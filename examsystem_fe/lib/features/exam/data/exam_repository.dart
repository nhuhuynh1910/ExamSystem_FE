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

/// Repository cho toàn bộ Exam feature.
/// Dùng DioClient.instance — token được tự động gắn bởi interceptor.
class ExamRepository {
  final Dio _dio = DioClient.instance;

  // ── GET /api/exams ──────────────────────────────────────────────────────────
  /// Lấy danh sách đề thi có phân trang, lọc theo môn học.
  Future<PaginatedExams> getExams({
    int? subjectId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get(
      ApiConstants.exams,
      queryParameters: {
        'SubjectId': ?subjectId,
        'PageNumber': pageNumber,
        'PageSize': pageSize,
      },
    );
    return PaginatedExams.fromJson(response.data as Map<String, dynamic>);
  }

  // ── GET /api/exams/{id} ─────────────────────────────────────────────────────
  /// Lấy chi tiết một đề thi theo ID.
  Future<ExamModel> getExamById(int examId) async {
    final response = await _dio.get(ApiConstants.examById(examId));
    return ExamModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── POST /api/exams/{examId}/check-access ───────────────────────────────────
  /// Kiểm tra Student có đủ quyền join hay không.
  /// Ném [DioException] khi BE trả 401/403/404/409.
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
  /// Bắt đầu hoặc resume bài làm của học sinh.
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
  /// Lấy danh sách câu hỏi của đề thi.
  Future<List<QuestionModel>> getExamQuestions(int examId) async {
    final response = await _dio.get(ApiConstants.examQuestions(examId));
    final rawList = response.data as List<dynamic>? ?? [];
    return rawList
        .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── GET /api/attempts/{attemptId} ───────────────────────────────────────────
  /// Lấy thông tin chi tiết một lượt thi (gồm câu hỏi & câu trả lời đã lưu).
  Future<AttemptDetailsResponse> getAttemptDetails(int attemptId) async {
    final response = await _dio.get(ApiConstants.attemptDetails(attemptId));
    return AttemptDetailsResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── POST /api/attempts/{attemptId}/answers ──────────────────────────────────
  /// Lưu câu trả lời của học sinh trong lúc làm bài.
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
  /// Nộp bài và kết thúc lượt thi.
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
  /// Lấy kết quả thi của sinh viên.
  Future<dynamic> getExamResult(int examId) async {
    final response = await _dio.get(ApiConstants.examResult(examId));
    return response.data;
  }
}
