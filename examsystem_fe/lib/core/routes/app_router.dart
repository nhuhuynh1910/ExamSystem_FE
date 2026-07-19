import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/storage_manager.dart';
import '../../features/ranking/screens/ranking_screen_khanh.dart';
import '../../features/question/screens/question_list_screen_khanh.dart';
import '../../features/subject/screens/assigned_subject_screen_khanh.dart';
import '../../features/teacher_request/screens/admin_teacher_requests_screen_khanh.dart';
import '../../features/teacher_request/screens/available_teacher_subject_screen_khanh.dart';
import '../../features/teacher_request/screens/my_teacher_requests_screen_khanh.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String examList = '/exams';
  static const String questionList = '/questions';
  static const String assignedSubjects = '/assigned-subjects';

  static const String availableTeacherSubjects =
      '/teacher-request/available-subjects';

  static const String myTeacherRequests =
      '/teacher-request/my-requests';

  static const String adminTeacherRequests =
      '/admin/teacher-requests';

  static const String examDetailPath = '/exams/:id';

  static String examDetail(int id) => '/exams/$id';
  static const String rankingPath = '/exams/:id/ranking';

  static String ranking(int examId) => '/exams/$examId/ranking';

  static final GoRouter router = GoRouter(
    // Mỗi lần khởi động app sẽ bắt đầu tại Login.
    initialLocation: login,

    redirect: _guardRedirect,

    routes: [
      GoRoute(
        path: login,
        name: 'login',
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const _PlaceholderScreen(
            routeName: 'Login Screen',
            routePath: '/login',
            assignee: 'Thành viên phụ trách: Auth Feature',
          );
        },
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const _PlaceholderScreen(
            routeName: 'Register Screen',
            routePath: '/register',
            assignee: 'Thành viên phụ trách: Auth Feature',
          );
        },
      ),

      GoRoute(
        path: examList,
        name: 'examList',
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const _PlaceholderScreen(
            routeName: 'Exam List Screen',
            routePath: '/exams',
            assignee: 'Thành viên phụ trách: Exam Feature',
          );
        },
        routes: [
          GoRoute(
            path: ':id',
            name: 'examDetail',
            builder: (
                BuildContext context,
                GoRouterState state,
                ) {
              final examId = state.pathParameters['id'] ?? '';

              return _PlaceholderScreen(
                routeName: 'Exam Detail Screen (id: $examId)',
                routePath: '/exams/$examId',
                assignee:
                'Thành viên phụ trách: Exam Detail Feature',
              );
            },
            routes: [
              GoRoute(
                path: 'ranking',
                name: 'ranking',
                builder: (
                    BuildContext context,
                    GoRouterState state,
                    ) {
                  final examId = int.tryParse(
                    state.pathParameters['id'] ?? '',
                  );

                  if (examId == null) {
                    return const Scaffold(
                      body: Center(
                        child: Text(
                          'Exam ID không hợp lệ.',
                        ),
                      ),
                    );
                  }

                  return RankingScreenKhanh(
                    examId: examId,
                  );
                },
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: questionList,
        name: 'questionList',
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const QuestionListScreenKhanh();
        },
      ),

      GoRoute(
        path: assignedSubjects,
        name: 'assignedSubjects',
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const AssignedSubjectScreenKhanh();
        },
      ),

      GoRoute(
        path: availableTeacherSubjects,
        name: 'availableTeacherSubjects',
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const AvailableTeacherSubjectScreenKhanh();
        },
      ),

      GoRoute(
        path: myTeacherRequests,
        name: 'myTeacherRequests',
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const MyTeacherRequestsScreenKhanh();
        },
      ),

      GoRoute(
        path: adminTeacherRequests,
        name: 'adminTeacherRequests',
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const AdminTeacherRequestsScreenKhanh();
        },
      ),
    ],

    errorBuilder: (
        BuildContext context,
        GoRouterState state,
        ) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lỗi điều hướng'),
        ),
        body: Center(
          child: Text(
            'Không tìm thấy trang: ${state.uri.path}',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
    },
  );

  /*
   * Protect private routes.
   *
   * The app is allowed to stay on Login even when an old token exists.
   * Navigation after successful login must be handled in LoginScreenKhanh.
   */
  static Future<String?> _guardRedirect(
      BuildContext context,
      GoRouterState state,
      ) async {
    final bool isLoggedIn =
    await StorageManager.isLoggedIn();

    final bool isPublicRoute =
        state.matchedLocation == login ||
            state.matchedLocation == register;

    // Chưa đăng nhập nhưng cố vào trang bên trong.
    if (!isLoggedIn && !isPublicRoute) {
      return login;
    }

    // Không tự động bỏ qua Login dù token cũ còn tồn tại.
    return null;
  }
}

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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.build_circle_outlined,
                size: 64,
                color: Colors.indigo,
              ),
              const SizedBox(height: 16),
              Text(
                routeName,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Route: $routePath',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  border: Border.all(
                    color: Colors.amber,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '📌 $assignee\nsẽ implement màn hình này.',
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
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