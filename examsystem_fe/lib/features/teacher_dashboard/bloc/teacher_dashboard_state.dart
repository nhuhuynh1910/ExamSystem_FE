import '../models/teacher_exam_model.dart';

/// States cho TeacherDashboardBloc.
abstract class TeacherDashboardState {
  const TeacherDashboardState();
}

/// Trạng thái ban đầu.
class TeacherDashboardInitial extends TeacherDashboardState {
  const TeacherDashboardInitial();
}

/// Đang tải dữ liệu.
class TeacherDashboardLoading extends TeacherDashboardState {
  const TeacherDashboardLoading();
}

/// Tải thành công — chứa toàn bộ dữ liệu cần hiển thị.
class TeacherDashboardLoaded extends TeacherDashboardState {
  /// Tên giáo viên (lấy từ StorageManager).
  final String teacherName;

  /// Toàn bộ đề thi (chưa lọc).
  final List<TeacherExamModel> allExams;

  /// Đề thi sau khi lọc theo tab.
  final List<TeacherExamModel> filteredExams;

  /// Filter đang chọn: null = "All", 'Draft', 'Published', 'Closed'.
  final String? activeFilter;

  /// Tổng số đề thi.
  final int totalExams;

  /// Tổng câu hỏi (hiện mock = 0, vì API chưa trả field này).
  final int totalQuestions;

  /// Tổng lượt thi (hiện mock = 0).
  final int totalAttempts;

  const TeacherDashboardLoaded({
    required this.teacherName,
    required this.allExams,
    required this.filteredExams,
    this.activeFilter,
    required this.totalExams,
    required this.totalQuestions,
    required this.totalAttempts,
  });

  /// Tạo bản sao với filter mới (dùng khi đổi tab).
  TeacherDashboardLoaded copyWithFilter({
    required String? activeFilter,
    required List<TeacherExamModel> filteredExams,
  }) {
    return TeacherDashboardLoaded(
      teacherName: teacherName,
      allExams: allExams,
      filteredExams: filteredExams,
      activeFilter: activeFilter,
      totalExams: totalExams,
      totalQuestions: totalQuestions,
      totalAttempts: totalAttempts,
    );
  }
}

/// Lỗi không tải được dữ liệu.
class TeacherDashboardError extends TeacherDashboardState {
  final String message;
  const TeacherDashboardError(this.message);
}
