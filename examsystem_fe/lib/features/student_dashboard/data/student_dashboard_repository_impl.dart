import 'package:dio/dio.dart';

import '../../teacher_dashboard/models/paged_exam_result.dart';
import '../../Enrollment/models/subject_model.dart';
import 'student_dashboard_remote_data_source.dart';
import 'student_dashboard_repository.dart';

/// Implement repository — theo pattern TeacherDashboardRepositoryImpl.
class StudentDashboardRepositoryImpl implements StudentDashboardRepository {
  final StudentDashboardRemoteDataSource _remoteDataSource;

  StudentDashboardRepositoryImpl({
    StudentDashboardRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
            remoteDataSource ?? StudentDashboardRemoteDataSource();

  @override
  Future<PagedExamResult> getAvailableExams() async {
    try {
      return await _remoteDataSource.getAvailableExams();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(
        e,
        'Không thể tải danh sách bài thi. Vui lòng thử lại sau.',
      ));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> getUnreadNotificationCount() async {
    try {
      return await _remoteDataSource.getUnreadNotificationCount();
    } on DioException {
      // Nếu lỗi notification, trả về 0 (không critical)
      return 0;
    } catch (_) {
      return 0;
    }
  }

  String _extractErrorMessage(DioException e, String defaultMessage) {
    final response = e.response;
    if (response != null && response.data != null) {
      final data = response.data;
      if (data is Map) {
        final message = data['message'] as String?;
        if (message != null && message.isNotEmpty) return message;
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstEntry = errors.values.first;
          if (firstEntry is List && firstEntry.isNotEmpty) {
            return firstEntry.first.toString();
          }
        }
        final title = data['title'] as String?;
        if (title != null && title.isNotEmpty) return title;
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
    }
    return defaultMessage;
  }

  @override
  Future<List<dynamic>> getStudentSubjects(int studentId) async {
    try {
      return await _remoteDataSource.getStudentSubjects(studentId);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<SubjectModel>> getAvailableCatalogSubjects() async {
    try {
      final response = await _remoteDataSource.getAvailableCatalogSubjects();
      if (response is List) {
        return response
            .map((item) => SubjectModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
