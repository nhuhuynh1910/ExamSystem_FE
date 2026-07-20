import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/storage_manager.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/forgot_password_bloc.dart';
import '../../features/auth/bloc/google_register_bloc.dart';
import '../../features/auth/bloc/register_bloc.dart';
import '../../features/auth/bloc/reset_password_bloc.dart';
import '../../features/auth/data/google_auth_service.dart';
import '../../features/auth/screens/google_account_picker_screen.dart';
import '../../features/auth/screens/google_complete_registration_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/profile/bloc/profile_bloc.dart';
import '../../features/profile/bloc/profile_event.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/student_dashboard/bloc/student_dashboard_bloc.dart';
import '../../features/student_dashboard/bloc/student_dashboard_event.dart';
import '../../features/student_dashboard/presentation/screens/student_dashboard_screen.dart';
import '../../features/teacher_dashboard/bloc/teacher_dashboard_bloc.dart';
import '../../features/teacher_dashboard/bloc/teacher_dashboard_event.dart';
import '../../features/teacher_dashboard/presentation/screens/teacher_dashboard_screen.dart';
import '../../features/exam/block/exam_detail_cubit.dart';
import '../../features/exam/block/start_exam_cubit.dart';
import '../../features/exam/screens/exam_detail_screen.dart';
import '../../features/exam/screens/exam_list_screen.dart';
import '../../features/exam/screens/enter_access_code_screen.dart';
import '../../features/exam/models/exam_model.dart';
import '../../features/notification/screens/notification_list_screen.dart';
import '../../features/question/screens/question_list_screen.dart';
import '../../features/ranking/screens/ranking_screen_khanh.dart';
import '../../features/question/screens/question_list_screen_khanh.dart';
import '../../features/subject/screens/assigned_subject_screen_khanh.dart';
import '../../features/teacher_request/screens/admin_teacher_requests_screen_khanh.dart';
import '../../features/teacher_request/screens/available_teacher_subject_screen_khanh.dart';
import '../../features/teacher_request/screens/my_teacher_requests_screen_khanh.dart';

import '../../features/Subject_phat/screens/admin_course_management_screen.dart';
import '../../features/Subject_phat/screens/admin_create_course_screen.dart';
import '../../features/Subject_phat/screens/assign_teacher_screen.dart';
import '../../features/Subject_phat/screens/course_details_edit_screen.dart';
import '../../features/Subject_phat/screens/course_student_list_screen.dart';
import '../../features/common/feature_hub_screen.dart';
import '../../features/Enrollment/screens/course_registration_catalog_screen.dart';
import '../../features/Enrollment/screens/my_registered_courses_screen.dart';
import '../../features/Teacher_phat/screens/teacher_assigned_courses_screen.dart';
import '../../features/Teacher_phat/screens/teacher_course_roster_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// AppRouter — Hệ thống điều hướng hợp nhất & bảo vệ theo Role (Nhóm 3)
// ════════════════════════════════════════════════════════════════════════════
class AppRouter {
  // ── Hằng định nghĩa tên đường dẫn (Route Constants) ───────────────────────
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String googleRegister = '/register/google-complete';
  static const String googleAccountPicker = '/login/google-picker';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String profile = '/profile';

  // ── Dashboard / Home theo Role ────────────────────────────────────────────
  static const String featureHub = '/feature-hub';
  static const String teacherDashboard = '/teacher/dashboard';
  static const String studentDashboard = '/student/dashboard';

  // ── Khóa học & Môn học (Phi Phát & Lê Quốc Khánh) ─────────────────────────
  static const String adminCourses = '/admin/courses';
  static const String studentCatalog = '/student/courses/catalog';
  static const String studentRegistered = '/student/courses/registered';
  static const String teacherCourses = '/teacher/courses';
  static const String assignedSubjects = '/assigned-subjects';

  // ── Yêu cầu Giáo viên (Lê Quốc Khánh) ─────────────────────────────────────
  static const String availableTeacherSubjects = '/teacher-request/available-subjects';
  static const String myTeacherRequests = '/teacher-request/my-requests';
  static const String adminTeacherRequests = '/admin/teacher-requests';

  // ── Đề thi & Câu hỏi & Thông báo (Thanh Trúc & Như Huỳnh & Lê Quốc Khánh) ──
  static const String examList = '/exams';
  static const String examDetailPath = '/exams/:id';
  static String examDetail(int id) => '/exams/$id';

  static const String rankingPath = '/exams/:id/ranking';
  static String ranking(int examId) => '/exams/$examId/ranking';

  static const String questionList = '/questions';
  static const String questionBank = '/question-bank';
  static const String notifications = '/notifications';
  // ── Tập hợp các route public không cần xác thực ───────────────────────────
  static const Set<String> _publicRoutes = {
    splash,
    onboarding,
    login,
    register,
    googleRegister,
    googleAccountPicker,
    forgotPassword,
    resetPassword,
  };

  // ── GoRouter chính ────────────────────────────────────────────────────────
  static final GoRouter router = GoRouter(
    initialLocation: splash,
    redirect: _guardRedirect,
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Lỗi điều hướng')),
      body: Center(
        child: Text('Không tìm thấy trang: ${state.uri.path}'),
      ),
    ),
    routes: [
      // ── Core & Auth Routes ────────────────────────────────────────────────
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider<RegisterBloc>(create: (context) => RegisterBloc()),
            BlocProvider<GoogleRegisterBloc>(create: (context) => GoogleRegisterBloc()),
          ],
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: googleAccountPicker,
        name: 'googleAccountPicker',
        builder: (context, state) => BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
          child: const GoogleAccountPickerScreen(),
        ),
      ),
      GoRoute(
        path: googleRegister,
        name: 'googleRegister',
        builder: (context, state) {
          final profile = state.extra as GoogleUserProfile?;
          if (profile == null) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<RegisterBloc>(create: (context) => RegisterBloc()),
                BlocProvider<GoogleRegisterBloc>(create: (context) => GoogleRegisterBloc()),
              ],
              child: const RegisterScreen(),
            );
          }
          return BlocProvider<GoogleRegisterBloc>(
            create: (context) => GoogleRegisterBloc(),
            child: GoogleCompleteRegistrationScreen(googleProfile: profile),
          );
        },
      ),
      GoRoute(
        path: forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => BlocProvider<ForgotPasswordBloc>(
          create: (context) => ForgotPasswordBloc(),
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: resetPassword,
        name: 'resetPassword',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return BlocProvider<ResetPasswordBloc>(
            create: (context) => ResetPasswordBloc(),
            child: ResetPasswordScreen(token: token),
          );
        },
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider<ProfileBloc>(create: (context) => ProfileBloc()..add(const ProfileLoadRequested())),
            BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
          ],
          child: const ProfileScreen(),
        ),
      ),

      // ── Dashboards ────────────────────────────────────────────────────────
      GoRoute(
        path: featureHub,
        name: 'featureHub',
        builder: (context, state) => const FeatureHubScreen(),
      ),
      GoRoute(
        path: teacherDashboard,
        name: 'teacherDashboard',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider<TeacherDashboardBloc>(create: (context) => TeacherDashboardBloc()..add(const TeacherDashboardLoadRequested())),
            BlocProvider<ProfileBloc>(create: (context) => ProfileBloc()..add(const ProfileLoadRequested())),
            BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
          ],
          child: const TeacherDashboardScreen(),
        ),
      ),
      GoRoute(
        path: studentDashboard,
        name: 'studentDashboard',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider<StudentDashboardBloc>(create: (context) => StudentDashboardBloc()..add(const StudentDashboardLoadRequested())),
            BlocProvider<ProfileBloc>(create: (context) => ProfileBloc()..add(const ProfileLoadRequested())),
            BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
          ],
          child: const StudentDashboardScreen(),
        ),
      ),

      // ── Admin: Quản lý Môn học (Phi Phát) ─────────────────────────────────
      GoRoute(
        path: adminCourses,
        name: 'adminCourses',
        builder: (context, state) => const AdminCourseManagementScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'adminCreateCourse',
            builder: (context, state) => const AdminCreateCourseScreen(),
          ),
          GoRoute(
            path: ':code',
            name: 'adminCourseDetail',
            builder: (context, state) {
              final code = state.pathParameters['code'] ?? '0';
              return CourseDetailsEditScreen(courseCode: code);
            },
            routes: [
              GoRoute(
                path: 'students',
                name: 'adminCourseStudents',
                builder: (context, state) {
                  final code = state.pathParameters['code'] ?? '0';
                  return CourseStudentListScreen(courseCode: code);
                },
              ),
              GoRoute(
                path: 'assign-teacher',
                name: 'adminAssignTeacher',
                builder: (context, state) {
                  final code = state.pathParameters['code'] ?? '0';
                  return AssignTeacherScreen(courseCode: code);
                },
              ),
            ],
          ),
        ],
      ),

      // ── Student: Đăng ký Môn học (Phi Phát) ───────────────────────────────
      GoRoute(
        path: studentCatalog,
        name: 'studentCatalog',
        builder: (context, state) => const CourseRegistrationCatalogScreen(),
      ),
      GoRoute(
        path: studentRegistered,
        name: 'studentRegistered',
        builder: (context, state) => const MyRegisteredCoursesScreen(),
      ),

      // ── Teacher: Quản lý Lớp (Phi Phát & Lê Quốc Khánh) ───────────────────
      GoRoute(
        path: teacherCourses,
        name: 'teacherCourses',
        builder: (context, state) => const TeacherAssignedCoursesScreen(),
        routes: [
          GoRoute(
            path: ':code/roster',
            name: 'teacherCourseRoster',
            builder: (context, state) {
              final code = state.pathParameters['code'] ?? '0';
              return TeacherCourseRosterScreen(courseCode: code);
            },
          ),
        ],
      ),
      GoRoute(
        path: assignedSubjects,
        name: 'assignedSubjects',
        builder: (context, state) => const AssignedSubjectScreenKhanh(),
      ),

      // ── Teacher Requests (Lê Quốc Khánh) ──────────────────────────────────
      GoRoute(
        path: availableTeacherSubjects,
        name: 'availableTeacherSubjects',
        builder: (context, state) => const AvailableTeacherSubjectScreenKhanh(),
      ),
      GoRoute(
        path: myTeacherRequests,
        name: 'myTeacherRequests',
        builder: (context, state) => const MyTeacherRequestsScreenKhanh(),
      ),
      GoRoute(
        path: adminTeacherRequests,
        name: 'adminTeacherRequests',
        builder: (context, state) => const AdminTeacherRequestsScreenKhanh(),
      ),

      // ── Exams & Questions & Ranking (Thanh Trúc, Như Huỳnh, Lê Quốc Khánh) ─
      GoRoute(
        path: examList,
        name: 'examList',
        builder: (context, state) => const ExamListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'examDetail',
            builder: (context, state) {
              final examId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => ExamDetailCubit()..loadDetail(examId)),
                  BlocProvider(create: (_) => StartExamCubit()),
                ],
                child: ExamDetailScreen(examId: examId),
              );
            },
            routes: [
              GoRoute(
                path: 'access-code',
                name: 'examAccessCode',
                builder: (context, state) {
                  final examId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                  final examName = state.uri.queryParameters['name'] ?? '';
                  final duration = int.tryParse(state.uri.queryParameters['duration'] ?? '') ?? 60;
                  final endTimeStr = state.uri.queryParameters['endTime'] ?? '';
                  final endTime = DateTime.tryParse(endTimeStr);
                  return EnterAccessCodeScreen(
                    examId: examId,
                    examName: examName,
                    durationMinutes: duration,
                    endTime: endTime,
                  );
                },
              ),
              GoRoute(
                path: 'ranking',
                name: 'ranking',
                builder: (context, state) {
                  final examId = int.tryParse(state.pathParameters['id'] ?? '');
                  if (examId == null) {
                    return const Scaffold(
                      body: Center(child: Text('Exam ID không hợp lệ.')),
                    );
                  }
                  return RankingScreenKhanh(examId: examId);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: questionList,
        name: 'questionList',
        builder: (context, state) => const QuestionListScreenKhanh(),
      ),
      GoRoute(
        path: questionBank,
        name: 'questionBank',
        builder: (context, state) => const QuestionListScreen(),
      ),
      GoRoute(
        path: notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationListScreen(),
      ),
     
    ],
  );

  // ── Guard điều hướng theo Role & Authentication ───────────────────────────
  static Future<String?> _guardRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final String currentPath = state.matchedLocation;
    if (currentPath == splash) return null;

    final bool isLoggedIn = await StorageManager.isLoggedIn();
    final bool isPublicRoute = _publicRoutes.contains(currentPath);

    if (!isLoggedIn && !isPublicRoute) {
      return login;
    }

    if (isLoggedIn && isPublicRoute) {
      final role = await StorageManager.getRole() ?? 'Student';
      return _homeForRole(role);
    }

    if (isLoggedIn) {
      final role = await StorageManager.getRole() ?? 'Student';
      final String? denied = _checkRoleAccess(currentPath, role);
      if (denied != null) return denied;
    }

    return null;
  }

  static String _homeForRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return featureHub;
      case 'teacher':
        return teacherDashboard;
      default:
        return studentDashboard;
    }
  }

  static String? _checkRoleAccess(String location, String role) {
    final bool isAdminRoute = location.startsWith('/admin/');
    final bool isTeacherRoute = location.startsWith('/teacher/');
    final bool isStudentRoute = location.startsWith('/student/');
    final bool isFeatureHub = location == featureHub;

    switch (role.toLowerCase()) {
      case 'admin':
        return null;
      case 'teacher':
        if (isAdminRoute || isStudentRoute || isFeatureHub) {
          return teacherDashboard;
        }
        return null;
      default:
        if (isAdminRoute || isTeacherRoute || isFeatureHub) {
          return studentDashboard;
        }
        return null;
    }
  }
}

// ── Placeholder cho các màn hình chưa implement hoàn thiện ──────────────────
class _PlaceholderScreen extends StatelessWidget {
  final String routeName;
  final String routePath;
  final String assignee;

  const _PlaceholderScreen({
    required this.routeName,
    required this.routePath,
    this.assignee = "N/A",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(routeName),
        backgroundColor: const Color(0xFFF15A22),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.build_circle_outlined,
                size: 64,
                color: Color(0xFFF15A22),
              ),
              const SizedBox(height: 16),
              Text(
                routeName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Route: $routePath',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '📌 $assignee\nsẽ implement màn hình này.',
                  style: const TextStyle(color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
