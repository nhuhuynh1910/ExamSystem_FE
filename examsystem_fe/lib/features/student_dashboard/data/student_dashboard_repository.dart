import '../../teacher_dashboard/models/paged_exam_result.dart';

/// Interface repository cho Student Dashboard.
abstract class StudentDashboardRepository {
  /// Lấy danh sách đề thi khả dụng (Published) cho student.
  Future<PagedExamResult> getAvailableExams();

  /// Đếm số thông báo chưa đọc.
  Future<int> getUnreadNotificationCount();

  /// Lấy danh sách môn học sinh viên đã đăng ký
  Future<List<dynamic>> getStudentSubjects(int studentId);
}
