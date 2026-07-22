import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/enrollment_repository.dart';
import '../models/enrollment_model.dart';
import 'enrollment_event.dart';
import 'enrollment_state.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// EnrollmentBloc — Tầng trung gian giữa Screens và Data.
///
/// Nhận Events từ UI → gọi Repository lấy/xử lý dữ liệu → phát States về UI.
///
/// Ví dụ flow đăng ký môn học:
///   1. Screen dispatch EnrollSubject(subjectId)
///   2. Bloc gọi _repository.enrollSubject(subjectId)
///   3. Thành công → emit EnrollmentActionSuccess('Đăng ký thành công')
///   4. Screen listener bắt được → hiện SnackBar + dispatch LoadCatalog để refresh
/// ════════════════════════════════════════════════════════════════════════════
class EnrollmentBloc extends Bloc<EnrollmentEvent, EnrollmentState> {
  final EnrollmentRepository _repository;

  EnrollmentBloc(this._repository) : super(EnrollmentInitial()) {
    on<LoadCatalog>(_onLoadCatalog);
    on<LoadMyEnrollments>(_onLoadMyEnrollments);
    on<EnrollSubject>(_onEnrollSubject);
    on<UnenrollSubject>(_onUnenrollSubject);
  }

  /// Xử lý LoadCatalog: tải danh sách môn học và môn đã đăng ký từ API.
  Future<void> _onLoadCatalog(
    LoadCatalog event,
    Emitter<EnrollmentState> emit,
  ) async {
    emit(EnrollmentLoading());
    try {
      final results = await Future.wait([
        _repository.fetchCatalog(),
        _repository.fetchMyEnrollments(),
      ]);
      final subjects = results[0] as List<dynamic>;
      final myEnrollments = results[1] as List<EnrollmentModel>;
      emit(CatalogLoaded(
        subjects.cast(),
        enrolledSubjects: myEnrollments,
      ));
    } catch (e) {
      emit(EnrollmentLoadFailure(e.toString()));
    }
  }

  /// Xử lý LoadMyEnrollments: tải danh sách môn SV đã đăng ký.
  Future<void> _onLoadMyEnrollments(
    LoadMyEnrollments event,
    Emitter<EnrollmentState> emit,
  ) async {
    emit(EnrollmentLoading());
    try {
      final enrollments = await _repository.fetchMyEnrollments();
      emit(MyEnrollmentsLoaded(enrollments));
    } catch (e) {
      emit(EnrollmentLoadFailure(e.toString()));
    }
  }

  /// Xử lý EnrollSubject: đăng ký vào môn học.
  /// Không emit Loading để tránh mất dữ liệu đang hiển thị.
  /// Screen listener sẽ bắt ActionSuccess/ActionFailure để hiện SnackBar
  /// và dispatch LoadCatalog lại để refresh danh sách.
  String _getErrorMessage(dynamic e, String defaultMsg) {
    final errStr = e.toString();
    if (errStr.contains('409')) {
      return 'This course has already been enrolled or schedule conflicts!';
    }
    if (errStr.contains('401') || errStr.contains('403')) {
      return 'Session expired or insufficient permission.';
    }
    if (errStr.contains('404')) {
      return 'Course or data not found.';
    }
    if (errStr.contains('connection') || errStr.contains('timeout') || errStr.contains('502') || errStr.contains('503')) {
      return 'Cannot connect to server. Please try again later.';
    }
    return '$defaultMsg: $e';
  }

  Future<void> _onEnrollSubject(
    EnrollSubject event,
    Emitter<EnrollmentState> emit,
  ) async {
    try {
      await _repository.enrollSubject(event.subjectId);
      emit(EnrollmentActionSuccess('Course enrolled successfully.'));
    } catch (e) {
      emit(EnrollmentActionFailure(_getErrorMessage(e, 'Enrollment failed')));
    }
  }

  /// Xử lý UnenrollSubject: hủy đăng ký khỏi môn học.
  Future<void> _onUnenrollSubject(
    UnenrollSubject event,
    Emitter<EnrollmentState> emit,
  ) async {
    try {
      await _repository.unenrollSubject(event.subjectId);
      emit(EnrollmentActionSuccess('Unenrolled successfully.'));
    } catch (e) {
      emit(EnrollmentActionFailure(_getErrorMessage(e, 'Unenrollment failed')));
    }
  }
}
