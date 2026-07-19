import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/storage_manager.dart';
import '../../features/Subject_phat/screens/admin_course_management_screen.dart';
import '../../features/Subject_phat/screens/admin_create_course_screen.dart';
import '../../features/Subject_phat/screens/assign_teacher_screen.dart';
import '../../features/Subject_phat/screens/course_details_edit_screen.dart';
import '../../features/Subject_phat/screens/course_student_list_screen.dart';
import '../../features/common/feature_hub_screen.dart';
import '../../features/Enrollment/screens/course_registration_catalog_screen.dart';
import '../../features/Enrollment/screens/my_registered_courses_screen.dart';
import '../../features/Teacher_phat/screens/teacher_assigned_courses_screen.dart';
import '../../features/common/student_dashboard_screen.dart';
import '../../features/Teacher_phat/screens/teacher_course_roster_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// AppRouter — Hệ thống điều hướng + bảo vệ theo Role.
//
// GUARD LOGIC:
//   Chưa đăng nhập              → redirect về /login
//   Đã đăng nhập, vào /login    → redirect về trang chủ theo role
//   Admin cố vào /student/*     → redirect về /admin/courses
//   Student cố vào /admin/*     → redirect về /student/courses/catalog
//   Teacher cố vào /admin/*     → redirect về /teacher/courses
//
// LUỒNG SAU KHI ĐĂNG NHẬP:
//   Admin   → /feature-hub      (truy cập được /admin/*)
//   Teacher → /teacher/courses  (chỉ truy cập /teacher/*)
//   Student → /student/courses/catalog  (chỉ truy cập /student/*)
// ════════════════════════════════════════════════════════════════════════════
class AppRouter {
  // ── Hằng route ───────────────────────────────────────────────────────────
  static const String login          = '/login';
  static const String register       = '/register';
  static const String featureHub     = '/feature-hub';
  static const String adminCourses   = '/admin/courses';
  static const String studentCatalog = '/student/courses/catalog';
  static const String studentRegistered = '/student/courses/registered';
  static const String studentDashboard = '/student/dashboard';
  static const String teacherCourses = '/teacher/courses';
  static const String examList       = '/exams';
  static const String examDetailPath = '/exams/:id';

  static String examDetail(int id) => '/exams/$id';

  // ── GoRouter chính ───────────────────────────────────────────────────────
  static final GoRouter router = GoRouter(
    // Bắt đầu từ /login, guard sẽ redirect nếu đã đăng nhập
    initialLocation: login,
    redirect: _guardRedirect,

    routes: [
      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ── Feature Hub (Admin landing) ───────────────────────────────────────
      GoRoute(
        path: featureHub,
        name: 'featureHub',
        builder: (context, state) => const FeatureHubScreen(),
      ),

      // ── Admin: Quản lý Môn học ────────────────────────────────────────────
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

      // ── Student: Đăng ký Môn học ──────────────────────────────────────────
      GoRoute(
        path: studentDashboard,
        name: 'studentDashboard',
        builder: (context, state) => const StudentDashboardScreen(),
      ),
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

      // ── Teacher: Quản lý Lớp ─────────────────────────────────────────────
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

      // ── Exam (placeholder, sẽ được thành viên khác implement) ───────────
      GoRoute(
        path: examList,
        name: 'examList',
        builder: (context, state) => const _PlaceholderScreen(
          routeName: 'Exam List Screen',
          routePath: '/exams',
          assignee: 'Thành viên phụ trách: Exam Feature',
        ),
        routes: [
          GoRoute(
            path: ':id',
            name: 'examDetail',
            builder: (context, state) {
              final examId = state.pathParameters['id'] ?? '';
              return _PlaceholderScreen(
                routeName: 'Exam Detail (id: $examId)',
                routePath: '/exams/$examId',
                assignee: 'Thành viên phụ trách: Exam Detail Feature',
              );
            },
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Lỗi điều hướng')),
      body: Center(
        child: Text('Không tìm thấy trang: ${state.uri.path}'),
      ),
    ),
  );

  // ── Guard: kiểm tra auth + role trước mỗi lần điều hướng ────────────────
  static Future<String?> _guardRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final bool isLoggedIn = await StorageManager.isLoggedIn();
    final String location = state.matchedLocation;

    // Các route không cần đăng nhập
    final bool isPublicRoute = location == login || location == register;

    // ── Chưa đăng nhập → về login ──────────────────────────────────────────
    if (!isLoggedIn && !isPublicRoute) {
      return login;
    }

    // ── Đã đăng nhập + đang ở trang public → redirect về trang chủ ─────────
    if (isLoggedIn && isPublicRoute) {
      final role = await StorageManager.getRole() ?? 'Student';
      return _homeForRole(role);
    }

    // ── Đã đăng nhập → kiểm tra role có quyền vào route không ──────────────
    if (isLoggedIn) {
      final role = await StorageManager.getRole() ?? 'Student';
      final String? denied = _checkRoleAccess(location, role);
      if (denied != null) return denied;
    }

    return null; // cho phép điều hướng bình thường
  }

  /// Trả về trang chủ phù hợp theo role.
  static String _homeForRole(String role) {
    switch (role) {
      case 'Admin':
        return featureHub;
      case 'Teacher':
        return teacherCourses;
      default: // Student
        return studentDashboard;
    }
  }

  /// Kiểm tra role có quyền vào route không.
  /// Trả về redirect path nếu bị từ chối, null nếu được phép.
  static String? _checkRoleAccess(String location, String role) {
    // Route chỉ dành cho Admin
    final bool isAdminRoute = location.startsWith('/admin/');
    // Route chỉ dành cho Teacher
    final bool isTeacherRoute = location.startsWith('/teacher/');
    // Route chỉ dành cho Student
    final bool isStudentRoute = location.startsWith('/student/');
    // Feature hub chỉ dành cho Admin
    final bool isFeatureHub = location == featureHub;

    switch (role) {
      case 'Admin':
        // Admin được truy cập mọi route (feature-hub, /admin/*, và cả /student/*, /teacher/*)
        return null;

      case 'Teacher':
        if (isAdminRoute || isStudentRoute || isFeatureHub) {
          return teacherCourses; // redirect về trang Teacher
        }
        return null;

      default: // Student
        if (isAdminRoute || isTeacherRoute || isFeatureHub) {
          return studentCatalog; // redirect về trang Student
        }
        return null;
    }
  }
}

// ── Placeholder cho các màn hình chưa implement ──────────────────────────────
class _PlaceholderScreen extends StatelessWidget {
  final String routeName;
  final String routePath;
  final String assignee;

  const _PlaceholderScreen({
    required this.routeName,
    required this.routePath,
    required this.assignee,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(routeName),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.build_circle_outlined, size: 64, color: Colors.indigo),
              const SizedBox(height: 16),
              Text(
                routeName,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Route: $routePath',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
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
