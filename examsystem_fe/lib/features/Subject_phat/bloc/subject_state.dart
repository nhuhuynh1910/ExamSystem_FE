import '../models/student_model.dart';
import '../models/subject_model.dart';
import '../models/teacher_in_subject_model.dart';
import '../models/teacher_user_model.dart';

sealed class SubjectState {}

/// Trạng thái ban đầu
final class SubjectInitial extends SubjectState {}

/// Đang tải/thực thi
final class SubjectLoading extends SubjectState {}

/// Tải thành công danh sách môn học
final class SubjectsLoaded extends SubjectState {
  final List<SubjectModel> subjects;
  SubjectsLoaded(this.subjects);
}

/// Tải thành công chi tiết một môn học
final class SubjectDetailLoaded extends SubjectState {
  final SubjectModel subject;
  SubjectDetailLoaded(this.subject);
}

/// Tải thành công danh sách học sinh của một môn học
final class SubjectStudentsLoaded extends SubjectState {
  final List<StudentModel> students;
  SubjectStudentsLoaded(this.students);
}

/// Thực hiện hành động CRUD thành công (Tạo, Sửa, Xóa)
final class SubjectActionSuccess extends SubjectState {
  final String message;
  SubjectActionSuccess(this.message);
}

/// Gặp lỗi khi tải dữ liệu hoặc hành động thất bại
final class SubjectFailure extends SubjectState {
  final String errorMessage;
  SubjectFailure(this.errorMessage);
}

/// Đã tải thành công danh sách tất cả Giáo viên + Giáo viên đang gán vào môn
final class AllTeachersLoaded extends SubjectState {
  final List<TeacherUserModel> allTeachers;
  final List<TeacherInSubjectModel> assignedTeachers;
  AllTeachersLoaded({
    required this.allTeachers,
    required this.assignedTeachers,
  });
}

/// Đã tải thành công danh sách Giáo viên đang gán vào môn
final class SubjectTeachersLoaded extends SubjectState {
  final List<TeacherInSubjectModel> teachers;
  SubjectTeachersLoaded(this.teachers);
}

/// Gán / Gỡ Giáo viên thành công (Listener hiện SnackBar + re-fetch)
final class SubjectTeacherActionSuccess extends SubjectState {
  final String message;
  SubjectTeacherActionSuccess(this.message);
}
