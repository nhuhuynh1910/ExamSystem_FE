

sealed class SubjectEvent {}

/// Tải danh sách tất cả môn học (Admin quản lý)
final class LoadSubjects extends SubjectEvent {}

/// Tải chi tiết 1 môn học theo ID
final class LoadSubjectDetail extends SubjectEvent {
  final int subjectId;
  LoadSubjectDetail(this.subjectId);
}

/// Tạo môn học mới
final class CreateSubjectEvent extends SubjectEvent {
  final String subjectName;
  final String description;
  CreateSubjectEvent({required this.subjectName, required this.description});
}

/// Cập nhật môn học
final class UpdateSubjectEvent extends SubjectEvent {
  final int subjectId;
  final String subjectName;
  final String description;
  final bool isActive;
  UpdateSubjectEvent({
    required this.subjectId,
    required this.subjectName,
    required this.description,
    required this.isActive,
  });
}

/// Xóa môn học
final class DeleteSubjectEvent extends SubjectEvent {
  final int subjectId;
  DeleteSubjectEvent(this.subjectId);
}

/// Tải danh sách học sinh đã enroll môn học
final class LoadSubjectStudents extends SubjectEvent {
  final int subjectId;
  LoadSubjectStudents(this.subjectId);
}

/// Tải danh sách tất cả Giáo viên (để Admin chọn gán)
final class LoadAllTeachers extends SubjectEvent {
  final int subjectId; // cần để đồng thời load GV đang được gán
  LoadAllTeachers(this.subjectId);
}

/// Tải danh sách Giáo viên đang được gán vào môn học
final class LoadSubjectTeachers extends SubjectEvent {
  final int subjectId;
  LoadSubjectTeachers(this.subjectId);
}

/// Admin gán Giáo viên vào môn học
final class AssignTeacher extends SubjectEvent {
  final int subjectId;
  final int teacherId;
  AssignTeacher({required this.subjectId, required this.teacherId});
}

/// Admin gỡ Giáo viên khỏi môn học
final class UnassignTeacher extends SubjectEvent {
  final int subjectId;
  final int teacherId;
  UnassignTeacher({required this.subjectId, required this.teacherId});
}
