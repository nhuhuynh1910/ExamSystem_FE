import 'package:dio/dio.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';

import '../models/add_exam_question_request.dart';
import '../models/exam_create_request.dart';
import '../models/exam_model.dart';
import '../models/exam_question_model.dart';
import '../models/exam_update_request.dart';
import '../models/subject_model.dart';

class ExamApi {
  final Dio _dio = DioClient.instance;

  //==========================================================
  // SUBJECT
  //==========================================================

  Future<List<SubjectModel>> getSubjects() async {
    final response = await _dio.get(ApiConstants.subjects);
    final data = response.data;
    List list = [];

    if (data is List) {
      list = data;
    } else if (data is Map && data['items'] is List) {
      list = data['items'];
    }

    return list.map((e) => SubjectModel.fromJson(e)).toList();
  }

  Future<List<SubjectModel>> getTeacherSubjects() async {

    final response =
    await _dio.get(ApiConstants.teacherSubjects);

    final List data = response.data is List
        ? response.data
        : [];

    final subjects = <SubjectModel>[];

    final Set<int> ids = {};

    for (final item in data) {

      final status =
      item['status']?.toString().toLowerCase();

      if (status != "approved") {
        continue;
      }


      final subjectId =
          int.tryParse(
              item['subjectId'].toString()
          ) ?? 0;


      if(subjectId == 0 || ids.contains(subjectId)){
        continue;
      }


      subjects.add(
          SubjectModel(
            subjectId: subjectId,
            subjectName:
            item['subjectName'] ?? "Unknown",
            description:
            item['description'],
            isActive:true,
          )
      );


      ids.add(subjectId);
    }


    return subjects;
  }
  Future<List<SubjectModel>> getEnrolledSubjects(int studentId) async {
    final response = await _dio.get("/students/$studentId/subjects");
    final List data = response.data is List
        ? response.data
        : (response.data['items'] ?? []);

    return data.map((e) => SubjectModel.fromJson(e)).toList();
  }

  //==========================================================
  // EXAM (CRUD & FILTERS)
  //==========================================================

  Future<List<ExamModel>> getExams({
    int? subjectId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get(
      ApiConstants.exams,
      queryParameters: {
        "PageNumber": pageNumber,
        "PageSize": pageSize,
        if (subjectId != null) "SubjectId": subjectId,
      },
    );

    final List items = response.data is Map 
        ? (response.data["items"] ?? []) 
        : (response.data is List ? response.data : []);
        
    return items.map((e) => ExamModel.fromJson(e)).toList();
  }

  Future<List<ExamModel>> getTeacherExams({
    String? status,
    int? subjectId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get(
      ApiConstants.teacherExams,
      queryParameters: {
        "PageNumber": pageNumber,
        "PageSize": pageSize,
        if (status != null) "Status": status,
        if (subjectId != null) "SubjectId": subjectId,
      },
    );

    final List items = response.data is Map 
        ? (response.data["items"] ?? []) 
        : (response.data is List ? response.data : []);

    return items.map((e) => ExamModel.fromJson(e)).toList();
  }

  Future<ExamModel> getExamById(int examId) async {
    final response = await _dio.get("${ApiConstants.exams}/$examId");
    return ExamModel.fromJson(response.data);
  }

  Future<ExamModel> createExam(ExamCreateRequest request) async {
    final response = await _dio.post(
      ApiConstants.exams,
      data: await request.toFormData(), // Dùng FormData vì Backend quy định [FromForm]
    );
    return ExamModel.fromJson(response.data);
  }

  Future<ExamModel> updateExam(int examId, ExamUpdateRequest request) async {
    final response = await _dio.put(
      "${ApiConstants.exams}/$examId",
      data: await request.toFormData(), // Dùng FormData vì Backend quy định [FromForm]
    );
    return ExamModel.fromJson(response.data);
  }

  Future<void> deleteExam(int examId) async {
    await _dio.delete("${ApiConstants.exams}/$examId");
  }

  /// Khôi phục đề thi đã xóa mềm thông qua endpoint status chung của Backend
  Future<ExamModel> restoreExam(int examId) async {
    final response = await _dio.put(
      "${ApiConstants.exams}/$examId/status",
      data: {
        "status": "Draft", // Backend tự động lật flag IsDeleted = false và chuyển trạng thái về Draft
      },
    );
    return ExamModel.fromJson(response.data);
  }

  Future<ExamModel> publishExam(int examId) async {
    final response = await _dio.put("${ApiConstants.exams}/$examId/publish");
    return ExamModel.fromJson(response.data);
  }

  Future<ExamModel> closeExam(int examId) async {
    final response = await _dio.put("${ApiConstants.exams}/$examId/close");
    return ExamModel.fromJson(response.data);
  }

  //==========================================================
  // EXAM QUESTION (Mối quan hệ đề thi - câu hỏi)
  //==========================================================

  Future<List<ExamQuestionModel>> getExamQuestions(int examId) async {
    final response = await _dio.get("${ApiConstants.exams}/$examId/questions");

    // Đề phòng trường hợp API trả về Object phân trang chứa key "items" thay vì mảng phẳng
    final List items = response.data is List
        ? response.data
        : (response.data['items'] ?? []);

    return items.map((e) => ExamQuestionModel.fromJson(e)).toList();
  }

  Future<void> addQuestion(int examId, AddExamQuestionRequest request) async {
    await _dio.post(
      "${ApiConstants.exams}/$examId/questions",
      data: await request.toFormData(), // Chuyển sang FormData đồng bộ với cấu trúc [FromForm] của API
    );
  }

  Future<void> removeQuestion(int examId, int questionId) async {
    await _dio.delete("${ApiConstants.exams}/$examId/questions/$questionId");
  }
}