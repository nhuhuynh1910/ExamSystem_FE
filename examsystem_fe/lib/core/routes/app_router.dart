import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/storage_manager.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/google_register_bloc.dart';
import '../../features/auth/bloc/register_bloc.dart';
import '../../features/auth/data/google_auth_service.dart';
import '../../features/auth/screens/google_account_picker_screen.dart';
import '../../features/auth/screens/google_complete_registration_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/splash/screens/splash_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// AppRouter — Hệ thống điều hướng tập trung của toàn bộ app.
//
// NGUYÊN TẮC:
//   - KHÔNG ai được tự thêm route vào main.dart hay bất kỳ Widget nào khác.
//   - MỌI route mới phải khai báo tại đây (thêm hằng tên route + GoRoute).
//   - Dùng context.go('/path') hoặc context.push('/path') để điều hướng,
//     KHÔNG dùng Navigator.push truyền thống.
//
// LUỒNG ĐIỀU HƯỚNG:
//   App start → /splash (2.5s delay + check token)
//     ├── [Có token] → /exams
//     └── [Không có token] → /onboarding → /login
//
// PUBLIC ROUTES (không cần auth): /splash, /onboarding, /login, /register
// PROTECTED ROUTES (cần auth): /exams, /exams/:id
// ════════════════════════════════════════════════════════════════════════════
class AppRouter {
  // ── Hằng định nghĩa tên đường dẫn ──────────────────────────────────────────

  /// Màn hình khởi động — điểm đầu tiên khi mở app.
  static const String splash = '/splash';

  /// Màn hình onboarding — giới thiệu app cho người dùng mới.
  static const String onboarding = '/onboarding';

  /// Màn hình đăng nhập — màn hình auth chính.
  static const String login = '/login';

  /// Màn hình đăng ký tài khoản mới.
  static const String register = '/register';

  /// Màn hình hoàn tất đăng ký bằng Google.
  static const String googleRegister = '/register/google-complete';

  /// Màn hình chọn tài khoản Google để đăng nhập.
  static const String googleAccountPicker = '/login/google-picker';

  /// Màn hình danh sách đề thi (trang chủ sau khi đăng nhập).
  static const String examList = '/exams';

  /// Màn hình chi tiết một đề thi theo ID.
  static const String examDetailPath = '/exams/:id';

  /// Helper tạo đường dẫn chi tiết đề thi với ID cụ thể.
  static String examDetail(int id) => '/exams/$id';

  // ── Tập hợp các route không cần xác thực (public) ──────────────────────
  static const Set<String> _publicRoutes = {
    splash,
    onboarding,
    login,
    register,
    googleRegister,
    googleAccountPicker,
  };

  // ── Khởi tạo GoRouter chính ─────────────────────────────────────────────
  static final GoRouter router = GoRouter(
    // Màn hình đầu tiên: SplashScreen.
    // GoRouter Guard sẽ KHÔNG redirect khi ở /splash (là public route).
    initialLocation: splash,

    // Hàm guard: kiểm tra xác thực trước mỗi lần điều hướng.
    redirect: _guardRedirect,

    // Danh sách tất cả các route của app.
    routes: [
      // ── Route: Splash Screen ──────────────────────────────────────────────
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),

      // ── Route: Onboarding Screen ──────────────────────────────────────────
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingScreen();
        },
      ),

      // ── Route: Đăng nhập ─────────────────────────────────────────────────
      // TODO: Thành viên phụ trách tính năng Auth sẽ đè màn hình thật vào đây sau.
      GoRoute(
        path: login,
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(),
            child: const LoginScreen(),
          );
        },
      ),

      // ── Route: Google Account Picker ──────────────────────────────
      GoRoute(
        path: googleAccountPicker,
        name: 'googleAccountPicker',
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(),
            child: const GoogleAccountPickerScreen(),
          );
        },
      ),

      // ── Route: Đăng ký ───────────────────────────────────────────
      GoRoute(
        path: register,
        name: 'register',
        builder: (BuildContext context, GoRouterState state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<RegisterBloc>(
                create: (context) => RegisterBloc(),
              ),
              BlocProvider<GoogleRegisterBloc>(
                create: (context) => GoogleRegisterBloc(),
              ),
            ],
            child: const RegisterScreen(),
          );
        },
      ),

      // ── Route: Hoàn tất đăng ký bằng Google ──────────────────────
      GoRoute(
        path: googleRegister,
        name: 'googleRegister',
        builder: (BuildContext context, GoRouterState state) {
          // Nhận GoogleUserProfile từ extra khi navigate
          final profile = state.extra as GoogleUserProfile?;

          // Fallback nếu không có profile (deep link trực tiếp)
          if (profile == null) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<RegisterBloc>(
                  create: (context) => RegisterBloc(),
                ),
                BlocProvider<GoogleRegisterBloc>(
                  create: (context) => GoogleRegisterBloc(),
                ),
              ],
              child: const RegisterScreen(),
            );
          }

          return BlocProvider<GoogleRegisterBloc>(
            create: (context) => GoogleRegisterBloc(),
            child: GoogleCompleteRegistrationScreen(
              googleProfile: profile,
            ),
          );
        },
      ),

      // ── Route: Danh sách đề thi (trang chủ) ─────────────────────────────
      // TODO: Thành viên phụ trách tính năng Exam sẽ đè màn hình thật vào đây sau.
      GoRoute(
        path: examList,
        name: 'examList',
        builder: (BuildContext context, GoRouterState state) {
          return const _PlaceholderScreen(
            routeName: 'Exam List Screen',
            routePath: '/exams',
            assignee: 'Thành viên phụ trách: Exam Feature',
          );
        },

        // ── Sub-route: Chi tiết đề thi ──────────────────────────────────
        routes: [
          GoRoute(
            path: ':id', // Đường dẫn đầy đủ: /exams/:id
            name: 'examDetail',
            builder: (BuildContext context, GoRouterState state) {
              final examId = state.pathParameters['id'] ?? '';
              return _PlaceholderScreen(
                routeName: 'Exam Detail Screen (id: $examId)',
                routePath: '/exams/$examId',
                assignee: 'Thành viên phụ trách: Exam Detail Feature',
              );
            },
          ),
        ],
      ),
    ],

    // Callback khi GoRouter gặp lỗi.
    errorBuilder: (BuildContext context, GoRouterState state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi điều hướng')),
        body: Center(
          child: Text(
            'Không tìm thấy trang: ${state.uri.path}',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    },
  );

  // ── Hàm guard điều hướng (authentication gate) ──────────────────────────
  /// Được GoRouter gọi trước MỌI lần chuyển màn hình.
  ///
  /// Logic:
  ///   - /splash → luôn cho qua (SplashScreen tự xử lý navigate).
  ///   - Đã đăng nhập + đang ở public route (trừ /splash) → redirect /exams.
  ///   - Chưa đăng nhập + cố vào route cần auth → redirect /onboarding.
  ///   - Các trường hợp còn lại → cho đi bình thường (return null).
  static Future<String?> _guardRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final String currentPath = state.matchedLocation;

    // /splash tự xử lý navigate sau delay — không can thiệp.
    if (currentPath == splash) return null;

    // Kiểm tra trạng thái đăng nhập từ StorageManager (local, không gọi API).
    final bool isLoggedIn = await StorageManager.isLoggedIn();

    // Xác định route hiện tại có phải public không.
    final bool isPublicRoute = _publicRoutes.contains(currentPath);

    // Đã đăng nhập + đang ở trang public → vào thẳng trang chủ.
    if (isLoggedIn && isPublicRoute) {
      return examList;
    }

    // Chưa đăng nhập + cố vào trang cần auth → về Onboarding.
    if (!isLoggedIn && !isPublicRoute) {
      return onboarding;
    }

    // Mọi trường hợp còn lại → điều hướng bình thường.
    return null;
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _PlaceholderScreen — Màn hình tạm thời cho các tính năng chưa implement.
//
// Thành viên phụ trách tính năng sẽ XÓA và THAY THẾ builder trong GoRoute.
// ════════════════════════════════════════════════════════════════════════════
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
        backgroundColor: const Color(0xFFF15A22), // FPT Orange
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Route: $routePath',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
