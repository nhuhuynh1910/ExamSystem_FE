/// ════════════════════════════════════════════════════════════════════════════
/// EnrollmentEvent — Các sự kiện mà UI gửi vào EnrollmentBloc.
///
/// Flow: Screen (dispatch Event) → Bloc (xử lý logic) → emit State
/// ════════════════════════════════════════════════════════════════════════════
sealed class EnrollmentEvent {}

/// Tải danh sách tất cả môn học (catalog) để sinh viên duyệt đăng ký.
final class LoadCatalog extends EnrollmentEvent {}

/// Tải danh sách các môn học mà sinh viên hiện tại đã đăng ký.
final class LoadMyEnrollments extends EnrollmentEvent {}

/// Sinh viên đăng ký vào 1 môn học.
final class EnrollSubject extends EnrollmentEvent {
  final int subjectId;
  EnrollSubject(this.subjectId);
}

/// Sinh viên hủy đăng ký khỏi 1 môn học.
final class UnenrollSubject extends EnrollmentEvent {
  final int subjectId;
  UnenrollSubject(this.subjectId);
}
