import '../models/paged_exam_result.dart';

/// Interface repository cho Teacher Dashboard.
abstract class TeacherDashboardRepository {
  /// Lấy danh sách đề thi của teacher hiện tại.
  Future<PagedExamResult> getTeacherExams({String? status});
}
