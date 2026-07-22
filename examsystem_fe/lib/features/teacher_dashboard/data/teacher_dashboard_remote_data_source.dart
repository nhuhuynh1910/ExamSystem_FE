import 'package:dio/dio.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/paged_exam_result.dart';

/// Nguồn dữ liệu từ xa — gọi API BE cho Teacher Dashboard.
///
/// Dùng DioClient.instance (singleton) — KHÔNG tạo Dio mới.
class TeacherDashboardRemoteDataSource {
  final Dio _dio;

  TeacherDashboardRemoteDataSource({Dio? dio})
      : _dio = dio ?? DioClient.instance;

  /// GET /api/teacher/exams
  ///
  /// Query params theo TeacherExamFilterRequestDto.cs:
  ///   - subjectId (int?, optional)
  ///   - status (string?, optional): 'Draft', 'Published', 'Closed'
  ///   - pageNumber (int, default 1)
  ///   - pageSize (int, default 10)
  Future<PagedExamResult> getTeacherExams({
    int? subjectId,
    String? status,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    final response = await _dio.get(
      ApiConstants.teacherExams,
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (subjectId != null) 'subjectId': subjectId,
        if (status != null) 'status': status,
      },
    );
    return PagedExamResult.fromJson(response.data as Map<String, dynamic>);
  }
}
