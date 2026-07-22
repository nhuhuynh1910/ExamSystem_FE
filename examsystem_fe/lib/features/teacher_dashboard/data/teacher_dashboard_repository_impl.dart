import 'package:dio/dio.dart';

import '../models/paged_exam_result.dart';
import 'teacher_dashboard_remote_data_source.dart';
import 'teacher_dashboard_repository.dart';

/// Implement repository — theo pattern ProfileRepositoryImpl.
class TeacherDashboardRepositoryImpl implements TeacherDashboardRepository {
  final TeacherDashboardRemoteDataSource _remoteDataSource;

  TeacherDashboardRepositoryImpl({
    TeacherDashboardRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
            remoteDataSource ?? TeacherDashboardRemoteDataSource();

  @override
  Future<PagedExamResult> getTeacherExams({String? status}) async {
    try {
      return await _remoteDataSource.getTeacherExams(status: status);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(
        e,
        'Failed to load exam list. Please try again later.',
      ));
    } catch (e) {
      rethrow;
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
}
