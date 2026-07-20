import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/student_model.dart';
import '../models/subject_model.dart';
import '../models/teacher_in_subject_model.dart';
import '../models/teacher_user_model.dart';

class SubjectRepository {
  final _dio = DioClient.instance;

  Future<List<SubjectModel>> fetchSubjects() async {
    final response = await _dio.get(ApiConstants.subjects);
    if (response.data is List) {
      return (response.data as List)
          .map((item) => SubjectModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    return [];
  }

  Future<SubjectModel> fetchSubjectById(int subjectId) async {
    final response = await _dio.get('${ApiConstants.subjects}/$subjectId');
    return SubjectModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<SubjectModel> createSubject({
    required String subjectName,
    required String description,
  }) async {
    final response = await _dio.post(
      ApiConstants.subjects,
      data: {'subjectName': subjectName, 'description': description},
    );
    return SubjectModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<SubjectModel> updateSubject({
    required int subjectId,
    required String subjectName,
    required String description,
    bool isActive = true,
  }) async {
    final response = await _dio.put(
      '${ApiConstants.subjects}/$subjectId',
      data: {
        'subjectName': subjectName,
        'description': description,
        'isActive': isActive,
      },
    );
    return SubjectModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<void> deleteSubject(int subjectId) async {
    await _dio.delete('${ApiConstants.subjects}/$subjectId');
  }

  Future<List<StudentModel>> fetchSubjectStudents(int subjectId) async {
    final response = await _dio.get(
      '${ApiConstants.subjects}/$subjectId/students',
    );
    if (response.data is List) {
      return (response.data as List)
          .map((item) => StudentModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    return [];
  }

  // ─── Teacher Assignment ────────────────────────────────────────────────────

  /// Lấy danh sách tất cả tài khoản User có Role = Teacher.
  /// API: GET /api/users  (Admin only)
  Future<List<TeacherUserModel>> fetchAllTeachers() async {
    final response = await _dio.get('/users');
    if (response.data is List) {
      return (response.data as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .where((item) => item['role']?.toString() == 'Teacher')
          .map((item) => TeacherUserModel.fromJson(item))
          .toList();
    }
    return [];
  }

  /// Lấy danh sách giáo viên đang được gán cho một môn học.
  /// API: GET /api/subjects/{subjectId}/teachers
  Future<List<TeacherInSubjectModel>> fetchSubjectTeachers(int subjectId) async {
    final response = await _dio.get('${ApiConstants.subjects}/$subjectId/teachers');
    if (response.data is List) {
      return (response.data as List)
          .map((item) => TeacherInSubjectModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    return [];
  }

  /// Admin gán giáo viên vào môn học.
  /// API: POST /api/subjects/{subjectId}/assign-teacher/{teacherId}
  Future<TeacherInSubjectModel> assignTeacher(int subjectId, int teacherId) async {
    final response = await _dio.post(
      '${ApiConstants.subjects}/$subjectId/assign-teacher/$teacherId',
    );
    return TeacherInSubjectModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  /// Admin gỡ giáo viên khỏi môn học.
  /// API: DELETE /api/subjects/{subjectId}/unassign-teacher/{teacherId}
  Future<void> unassignTeacher(int subjectId, int teacherId) async {
    await _dio.delete('${ApiConstants.subjects}/$subjectId/unassign-teacher/$teacherId');
  }
}

