import '../../teacher_dashboard/models/teacher_exam_model.dart';
import '../models/student_subject_model.dart';

/// States cho StudentDashboardBloc.
abstract class StudentDashboardState {
  const StudentDashboardState();
}

/// Trạng thái ban đầu.
class StudentDashboardInitial extends StudentDashboardState {
  const StudentDashboardInitial();
}

/// Đang tải dữ liệu.
class StudentDashboardLoading extends StudentDashboardState {
  const StudentDashboardLoading();
}

/// Tải thành công — chứa toàn bộ dữ liệu cần hiển thị.
class StudentDashboardLoaded extends StudentDashboardState {
  /// Tên sinh viên (lấy từ StorageManager).
  final String studentName;

  /// Số thông báo chưa đọc (badge chuông header).
  final int unreadNotifications;

  /// Số môn học đã đăng ký (Stats Strip).
  final int enrolledCount;

  /// Số bài thi đã làm (Stats Strip).
  final int examsTakenCount;

  /// Điểm cao nhất (Stats Strip) — hiển thị dạng "95%".
  final String bestScore;

  /// Danh sách đề thi sắp tới (Upcoming Exams section).
  final List<TeacherExamModel> upcomingExams;

  /// Danh sách môn học đã đăng ký (My Subjects section).
  final List<StudentSubjectModel> subjects;

  const StudentDashboardLoaded({
    required this.studentName,
    required this.unreadNotifications,
    required this.enrolledCount,
    required this.examsTakenCount,
    required this.bestScore,
    required this.upcomingExams,
    required this.subjects,
  });
}

/// Lỗi không tải được dữ liệu.
class StudentDashboardError extends StudentDashboardState {
  final String message;
  const StudentDashboardError(this.message);
}
