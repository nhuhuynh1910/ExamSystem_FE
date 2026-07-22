import '../../teacher_dashboard/models/paged_exam_result.dart';
import '../../Enrollment/models/subject_model.dart';

/// Interface repository cho Student Dashboard.
abstract class StudentDashboardRepository {
  /// Lấy danh sách đề thi khả dụng (Published) cho student.
  Future<PagedExamResult> getAvailableExams();

  /// Đếm số thông báo chưa đọc.
  Future<int> getUnreadNotificationCount();

  /// Lấy danh sách môn học sinh viên đã đăng ký
  Future<List<dynamic>> getStudentSubjects(int studentId);

  /// Lấy danh sách tất cả môn học mở có sẵn để đăng ký (Catalog)
  Future<List<SubjectModel>> getAvailableCatalogSubjects();
}
