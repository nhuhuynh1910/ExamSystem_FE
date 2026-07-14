import 'package:dio/dio.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../teacher_dashboard/models/paged_exam_result.dart';

/// Nguồn dữ liệu từ xa — gọi API BE cho Student Dashboard.
///
/// Dùng DioClient.instance (singleton) — KHÔNG tạo Dio mới.
class StudentDashboardRemoteDataSource {
  final Dio _dio;

  StudentDashboardRemoteDataSource({Dio? dio})
      : _dio = dio ?? DioClient.instance;

  /// GET /api/exams — Student chỉ thấy exam Published (BE tự filter theo role).
  ///
  /// Dùng để hiển thị "Upcoming Exams" section.
  Future<PagedExamResult> getAvailableExams({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.exams,
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );
    return PagedExamResult.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/notifications?isRead=false — Đếm số thông báo chưa đọc.
  ///
  /// Trả về tổng số notifications chưa đọc cho badge chuông header.
  Future<int> getUnreadNotificationCount() async {
    final response = await _dio.get(
      ApiConstants.notifications,
      queryParameters: {'isRead': false},
    );

    // API trả về list notifications, đếm length.
    final data = response.data;
    if (data is Map && data.containsKey('items')) {
      return (data['items'] as List).length;
    }
    if (data is List) {
      return data.length;
    }
    // Fallback: nếu API trả totalItems
    if (data is Map && data.containsKey('totalItems')) {
      return data['totalItems'] as int;
    }
    return 0;
  }
}
