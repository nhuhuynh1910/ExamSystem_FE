import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/exam_model.dart';
import '../models/exam_question_model.dart';
import '../models/exam_create_request.dart';
import '../models/exam_update_request.dart';
import '../models/add_exam_question_request.dart';
import '../models/subject_model.dart';

class ExamApi {
  final Dio _dio = DioClient.instance;

  Future<List<SubjectModel>> getSubjects() async {
    final response = await _dio.get(ApiConstants.subjects);
    // .NET often returns a direct array for List<SubjectResponseDto>
    final dynamic data = response.data;
    List list = [];
    if (data is List) {
      list = data;
    } else if (data is Map && data['items'] is List) {
      list = data['items'];
    }
    return list.map((json) => SubjectModel.fromJson(json)).toList();
  }

  Future<List<SubjectModel>> getTeacherSubjects() async {
    try {
      final response = await _dio.get(ApiConstants.teacherRequestsMy);
      final List data = response.data is List ? response.data : (response.data['items'] ?? []);
      
      final approvedRequests = data.where((req) {
        final status = (req['status'] ?? req['Status'] ?? '').toString().toLowerCase();
        return status == 'approved';
      }).toList();
      
      return approvedRequests.map((req) => SubjectModel.fromJson(req)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<SubjectModel>> getEnrolledSubjects(int studentId) async {
    final response = await _dio.get('/students/$studentId/subjects');
    final List data = response.data is List ? response.data : (response.data['items'] ?? []);
    return data.map((json) => SubjectModel.fromJson(json)).toList();
  }

  Future<List<ExamModel>> getExams({int? subjectId, int pageNumber = 1, int pageSize = 10}) async {
    final Map<String, dynamic> query = {
      'PageNumber': pageNumber,
      'PageSize': pageSize,
    };
    if (subjectId != null) query['SubjectId'] = subjectId;

    final response = await _dio.get(
      ApiConstants.exams,
      queryParameters: query,
    );
    final List data = response.data['items'] ?? [];
    return data.map((json) => ExamModel.fromJson(json)).toList();
  }

  Future<ExamModel> getExamById(int examId) async {
    final response = await _dio.get('${ApiConstants.exams}/$examId');
    return ExamModel.fromJson(response.data);
  }

  Future<ExamModel> createExam(ExamCreateRequest request) async {
    final formData = await request.toFormData();
    final response = await _dio.post(ApiConstants.exams, data: formData);
    return ExamModel.fromJson(response.data);
  }

  Future<ExamModel> updateExam(int examId, ExamUpdateRequest request) async {
    final formData = await request.toFormData();
    final response = await _dio.put('${ApiConstants.exams}/$examId', data: formData);
    return ExamModel.fromJson(response.data);
  }

  Future<void> deleteExam(int examId) async {
    await _dio.delete('${ApiConstants.exams}/$examId');
  }

  Future<void> restoreExam(int examId) async {
    await _dio.put(
      '${ApiConstants.exams}/$examId/status',
      data: {'status': 'Draft'},
    );
  }

  Future<void> publishExam(int examId) async {
    await _dio.put('${ApiConstants.exams}/$examId/publish');
  }

  Future<void> closeExam(int examId) async {
    await _dio.put('${ApiConstants.exams}/$examId/close');
  }

  Future<List<ExamQuestionModel>> getExamQuestions(int examId) async {
    final response = await _dio.get('${ApiConstants.exams}/$examId/questions');
    final List data = response.data;
    return data.map((json) => ExamQuestionModel.fromJson(json)).toList();
  }

  Future<void> addQuestion(int examId, AddExamQuestionRequest request) async {
    await _dio.post(
      '${ApiConstants.exams}/$examId/questions',
      data: request.toFormData(),
    );
  }

  Future<void> removeQuestion(int examId, int questionId) async {
    await _dio.delete('${ApiConstants.exams}/$examId/questions/$questionId');
  }

  Future<List<ExamModel>> getTeacherExams({String? status, int? subjectId, int pageNumber = 1, int pageSize = 10}) async {
    final Map<String, dynamic> query = {
      'PageNumber': pageNumber,
      'PageSize': pageSize,
    };
    if (status != null) query['Status'] = status;
    if (subjectId != null) query['SubjectId'] = subjectId;

    final response = await _dio.get(
      ApiConstants.teacherExams,
      queryParameters: query,
    );
    final List data = response.data['items'] ?? [];
    return data.map((json) => ExamModel.fromJson(json)).toList();
  }
}
