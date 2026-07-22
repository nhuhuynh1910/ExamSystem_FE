import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/storage_manager.dart';
import '../../Enrollment/models/subject_model.dart';
import '../data/student_dashboard_repository.dart';
import '../data/student_dashboard_repository_impl.dart';
import '../models/student_exam_model.dart';
import '../models/student_subject_model.dart';
import 'student_dashboard_event.dart';
import 'student_dashboard_state.dart';

/// BLoC quản lý logic Student Dashboard.
class StudentDashboardBloc
    extends Bloc<StudentDashboardEvent, StudentDashboardState> {
  final StudentDashboardRepository _repository;

  StudentDashboardBloc({StudentDashboardRepository? repository})
      : _repository = repository ?? StudentDashboardRepositoryImpl(),
        super(const StudentDashboardInitial()) {
    on<StudentDashboardLoadRequested>(_onLoad);
  }

  /// Load dữ liệu dashboard: tên SV + đề thi + notifications + môn đã ĐK + môn có thể ĐK.
  Future<void> _onLoad(
    StudentDashboardLoadRequested event,
    Emitter<StudentDashboardState> emit,
  ) async {
    emit(const StudentDashboardLoading());

    try {
      // Lấy tên sinh viên từ local storage.
      final fullName = await StorageManager.getFullName() ?? 'Student';

      final studentId = await StorageManager.getUserId();
      if (studentId == null) {
        throw Exception('User ID not found');
      }

      // Gọi API song song: đề thi + notification count + môn đã ĐK + tất cả môn mở
      final results = await Future.wait([
        _repository.getAvailableExams(),
        _repository.getUnreadNotificationCount(),
        _repository.getStudentSubjects(studentId),
        _repository.getAvailableCatalogSubjects(),
      ]);

      final examResult = results[0] as dynamic;
      final unreadCount = results[1] as int;
      final rawSubjects = results[2] as List<dynamic>;
      final catalogSubjects = results[3] as List<SubjectModel>;

      // Map sang StudentSubjectModel
      final enrolledSubjects = rawSubjects
          .map((s) => StudentSubjectModel.fromJson(s as Map<String, dynamic>))
          .toList();

      // Tập hợp ID và Tên các môn sinh viên ĐÃ ĐĂNG KÝ (Enroll)
      final enrolledSubjectIds = enrolledSubjects
          .map((s) => s.subjectId)
          .where((id) => id > 0)
          .toSet();

      final enrolledSubjectNames = enrolledSubjects
          .map((s) => s.subjectName.toLowerCase().trim())
          .where((n) => n.isNotEmpty)
          .toSet();

      // Lọc danh sách bài kiểm tra (Exams): Chỉ lấy bài kiểm tra thuộc môn SV đã Enroll
      final allExams = (examResult.items as List).cast<StudentExamModel>();
      final enrolledExams = allExams.where((exam) {
        final matchId = enrolledSubjectIds.contains(exam.subjectId);
        final matchName = exam.subjectName != null &&
            enrolledSubjectNames
                .contains(exam.subjectName!.toLowerCase().trim());
        return matchId || matchName;
      }).toList();

      emit(StudentDashboardLoaded(
        studentName: fullName,
        unreadNotifications: unreadCount,
        enrolledCount: enrolledSubjects.length,
        examsTakenCount: 0,
        bestScore: '0%',
        upcomingExams: enrolledExams,
        subjects: enrolledSubjects,
        availableCatalogSubjects: catalogSubjects,
      ));
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(StudentDashboardError(errorMessage));
    }
  }
}
