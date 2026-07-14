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

      // Gọi API song song: đề thi + notification count.
      final results = await Future.wait([
        _repository.getAvailableExams(),
        _repository.getUnreadNotificationCount(),
      ]);

      final examResult = results[0] as dynamic;
      final unreadCount = results[1] as int;

      // Mock subjects — BE chưa có API riêng.
      const mockSubjects = [
        StudentSubjectModel(
          subjectId: 1,
          subjectName: 'Software Engineering',
          teacherName: 'Dr. Le Van Nam',
          studentCount: 32,
        ),
        StudentSubjectModel(
          subjectId: 2,
          subjectName: 'Distributed Systems',
          teacherName: 'MSc. Hoang Thuy',
          studentCount: 28,
        ),
        StudentSubjectModel(
          subjectId: 3,
          subjectName: 'Mobile App Development',
          teacherName: 'Mr. Nguyen Quang',
          studentCount: 45,
        ),
      ];

      emit(StudentDashboardLoaded(
        studentName: fullName,
        unreadNotifications: unreadCount,
        enrolledCount: mockSubjects.length,
        examsTakenCount: 12, // Mock — BE chưa có API
        bestScore: '95%', // Mock — BE chưa có API
        upcomingExams: examResult.items,
        subjects: mockSubjects,
      ));
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(StudentDashboardError(errorMessage));
    }
  }
}
