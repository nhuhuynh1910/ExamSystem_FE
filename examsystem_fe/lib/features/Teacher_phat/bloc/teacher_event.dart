sealed class TeacherEvent {}

/// Tải danh sách môn học được phân công cho Giáo viên
final class LoadAssignedCourses extends TeacherEvent {}

/// Tải danh sách sinh viên trong lớp (Roster)
final class LoadCourseRoster extends TeacherEvent {
  final int subjectId;
  LoadCourseRoster(this.subjectId);
}
