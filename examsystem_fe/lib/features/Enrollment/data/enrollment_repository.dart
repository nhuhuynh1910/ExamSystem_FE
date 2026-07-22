import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/storage_manager.dart';
import '../models/enrollment_model.dart';
import '../models/subject_model.dart';

/// EnrollmentRepository — Tầng Data, giao tiếp trực tiếp với BE API.
///
/// Trả về Model thay vì Map thô để tầng Bloc và Screens
/// làm việc với dữ liệu có cấu trúc rõ ràng.
class EnrollmentRepository {
  final _dio = DioClient.instance;

  /// Tải danh sách tất cả môn học (catalog).
  /// API: GET /api/subjects
  Future<List<SubjectModel>> fetchCatalog() async {
    final response = await _dio.get(ApiConstants.subjects);
    if (response.data is List) {
      return (response.data as List)
          .map((item) => SubjectModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    }
    return [];
  }

  /// Tải danh sách các môn mà sinh viên hiện tại đã đăng ký.
  /// API: GET /api/students/{studentId}/subjects
  Future<List<EnrollmentModel>> fetchMyEnrollments() async {
    final studentId = await StorageManager.getUserId();
    if (studentId == null) return [];

    final response = await _dio.get('/students/$studentId/subjects');
    if (response.data is List) {
      return (response.data as List)
          .map((item) => EnrollmentModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    }
    return [];
  }

  /// Đăng ký vào môn học.
  /// API: POST /api/subjects/{subjectId}/enroll
  Future<void> enrollSubject(int subjectId) async {
    await _dio.post('${ApiConstants.subjects}/$subjectId/enroll');
  }

  /// Hủy đăng ký khỏi môn học.
  /// API: DELETE /api/subjects/{subjectId}/unenroll
  Future<void> unenrollSubject(int subjectId) async {
    await _dio.delete('${ApiConstants.subjects}/$subjectId/unenroll');
  }
}
