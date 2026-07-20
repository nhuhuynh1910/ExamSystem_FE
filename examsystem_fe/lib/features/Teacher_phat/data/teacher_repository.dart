import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/teacher_course_model.dart';
import '../models/teacher_student_model.dart';

class TeacherRepository {
  final _dio = DioClient.instance;

  /// Tải danh sách môn học được phân công cho Giáo viên đang đăng nhập.
  /// API: GET /api/subjects/assigned
  Future<List<TeacherCourseModel>> fetchAssignedCourses() async {
    final response = await _dio.get('${ApiConstants.subjects}/assigned');
    if (response.data is List) {
      return (response.data as List)
          .map((item) => TeacherCourseModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    }
    return [];
  }

  /// Tải danh sách học sinh của môn học từ API: GET /api/subjects/{subjectId}/students
  Future<List<TeacherStudentModel>> fetchCourseRoster(int subjectId) async {
    final response = await _dio.get(
      '${ApiConstants.subjects}/$subjectId/students',
    );
    if (response.data is List) {
      return (response.data as List)
          .map((item) => TeacherStudentModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    }
    return [];
  }
}

