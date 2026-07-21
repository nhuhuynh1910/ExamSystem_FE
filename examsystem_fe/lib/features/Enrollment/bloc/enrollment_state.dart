import '../models/enrollment_model.dart';
import '../models/subject_model.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// EnrollmentState — Các trạng thái mà EnrollmentBloc phát ra cho UI.
///
/// Flow: Bloc (xử lý xong) → emit State → Screen (BlocBuilder rebuild UI)
///
/// Phân loại:
///   - Builder states: UI rebuild theo states này (Initial, Loading, Loaded, LoadFailure)
///   - Listener states: UI chỉ hiện snackbar, không rebuild (ActionSuccess, ActionFailure)
/// ════════════════════════════════════════════════════════════════════════════
sealed class EnrollmentState {}

/// Trạng thái ban đầu khi Bloc vừa được tạo, chưa có dữ liệu.
final class EnrollmentInitial extends EnrollmentState {}

/// Đang tải dữ liệu từ API (hiển thị loading spinner).
final class EnrollmentLoading extends EnrollmentState {}

/// Đã tải thành công danh sách môn học catalog.
final class CatalogLoaded extends EnrollmentState {
  final List<SubjectModel> subjects;
  final List<EnrollmentModel>? enrolledSubjects;

  List<EnrollmentModel> get enrolledSubjectsList =>
      enrolledSubjects ?? const [];

  CatalogLoaded(this.subjects, {this.enrolledSubjects = const []});
}

/// Đã tải thành công danh sách môn sinh viên đã đăng ký.
final class MyEnrollmentsLoaded extends EnrollmentState {
  final List<EnrollmentModel> enrollments;
  MyEnrollmentsLoaded(this.enrollments);
}

/// Tải dữ liệu thất bại (hiển thị error message trên UI).
final class EnrollmentLoadFailure extends EnrollmentState {
  final String message;
  EnrollmentLoadFailure(this.message);
}

/// Enroll/Unenroll thành công (Listener hiện snackbar, rồi re-fetch data).
final class EnrollmentActionSuccess extends EnrollmentState {
  final String message;
  EnrollmentActionSuccess(this.message);
}

/// Enroll/Unenroll thất bại (Listener hiện snackbar lỗi).
final class EnrollmentActionFailure extends EnrollmentState {
  final String message;
  EnrollmentActionFailure(this.message);
}
