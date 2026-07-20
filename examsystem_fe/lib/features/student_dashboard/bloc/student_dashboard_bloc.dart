import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/storage_manager.dart';
import '../data/student_dashboard_repository.dart';
import '../data/student_dashboard_repository_impl.dart';
import '../models/student_subject_model.dart';
import 'student_dashboard_event.dart';
import 'student_dashboard_state.dart';

/// BLoC quản lý logic Student Dashboard.
///
/// Flow:
///   1. StudentDashboardLoadRequested → gọi API + StorageManager → emit Loaded
class StudentDashboardBloc
    extends Bloc<StudentDashboardEvent, StudentDashboardState> {
  final StudentDashboardRepository _repository;

  StudentDashboardBloc({StudentDashboardRepository? repository})
      : _repository = repository ?? StudentDashboardRepositoryImpl(),
        super(const StudentDashboardInitial()) {
    on<StudentDashboardLoadRequested>(_onLoad);
  }

  /// Load dữ liệu dashboard: tên SV + đề thi + notifications.
  Future<void> _onLoad(
    StudentDashboardLoadRequested event,
    Emitter<StudentDashboardState> emit,
  ) async {
    emit(const StudentDashboardLoading());

    try {
      // Lấy tên sinh viên từ local storage (không gọi API).
      final fullName = await StorageManager.getFullName() ?? 'Student';

      final studentId = await StorageManager.getUserId();
      if (studentId == null) {
        throw Exception('User ID not found');
      }

      // Gọi API song song: đề thi + notification count + danh sách môn học
      final results = await Future.wait([
        _repository.getAvailableExams(),
        _repository.getUnreadNotificationCount(),
        _repository.getStudentSubjects(studentId),
      ]);

      final examResult = results[0] as dynamic;
      final unreadCount = results[1] as int;
      final rawSubjects = results[2] as List<dynamic>;

      // Map sang StudentSubjectModel
      final subjects = rawSubjects.map((s) => StudentSubjectModel.fromJson(s as Map<String, dynamic>)).toList();

      emit(StudentDashboardLoaded(
        studentName: fullName,
        unreadNotifications: unreadCount,
        enrolledCount: subjects.length,
        examsTakenCount: 0, // Mock — BE chưa có API
        bestScore: '0%', // Mock — BE chưa có API
        upcomingExams: examResult.items,
        subjects: subjects,
      ));
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(StudentDashboardError(errorMessage));
    }
  }
}
