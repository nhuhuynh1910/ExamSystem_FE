import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/storage_manager.dart';
import '../data/teacher_dashboard_repository.dart';
import '../data/teacher_dashboard_repository_impl.dart';
import 'teacher_dashboard_event.dart';
import 'teacher_dashboard_state.dart';

/// BLoC quản lý logic Teacher Dashboard.
///
/// Flow:
///   1. TeacherDashboardLoadRequested → gọi API + StorageManager → emit Loaded
///   2. TeacherDashboardFilterChanged → lọc allExams theo status → emit Loaded mới
class TeacherDashboardBloc
    extends Bloc<TeacherDashboardEvent, TeacherDashboardState> {
  final TeacherDashboardRepository _repository;

  TeacherDashboardBloc({TeacherDashboardRepository? repository})
      : _repository = repository ?? TeacherDashboardRepositoryImpl(),
        super(const TeacherDashboardInitial()) {
    on<TeacherDashboardLoadRequested>(_onLoad);
    on<TeacherDashboardFilterChanged>(_onFilterChanged);
  }

  /// Load dữ liệu dashboard: tên GV + danh sách đề thi.
  Future<void> _onLoad(
    TeacherDashboardLoadRequested event,
    Emitter<TeacherDashboardState> emit,
  ) async {
    emit(const TeacherDashboardLoading());

    try {
      // Lấy tên giáo viên từ local storage (không gọi API).
      final fullName = await StorageManager.getFullName() ?? 'Teacher';

      // Gọi API lấy danh sách đề thi (pageSize lớn để lấy hết).
      final result = await _repository.getTeacherExams();

      emit(TeacherDashboardLoaded(
        teacherName: fullName,
        allExams: result.items,
        filteredExams: result.items, // Ban đầu hiển thị tất cả
        activeFilter: null,
        totalExams: result.items.length,
        // Mock: API chưa trả totalQuestions/totalAttempts per exam
        totalQuestions: 0,
        totalAttempts: 0,
      ));
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(TeacherDashboardError(errorMessage));
    }
  }

  /// Lọc đề thi theo status tab.
  void _onFilterChanged(
    TeacherDashboardFilterChanged event,
    Emitter<TeacherDashboardState> emit,
  ) {
    final currentState = state;
    if (currentState is! TeacherDashboardLoaded) return;

    final filtered = event.status == null
        ? currentState.allExams
        : currentState.allExams
            .where((e) =>
                e.status.toLowerCase() == event.status!.toLowerCase())
            .toList();

    emit(currentState.copyWithFilter(
      activeFilter: event.status,
      filteredExams: filtered,
    ));
  }
}
