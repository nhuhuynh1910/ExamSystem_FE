import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/storage_manager.dart';
import '../../features/attempt/screens/waiting_room_screen.dart';
import '../../features/auth/screens/login_screen.dart'; 
import '../../features/exam/models/exam_model.dart';
import '../../features/exam/screens/exam_list_screen.dart'; 
import '../../features/exam/screens/exam_detail_screen.dart'; 
import '../../features/notification/screens/notification_list_screen.dart';
import '../../features/question/screens/question_list_screen.dart';
import '../utils/token_storage.dart';

// ════════════════════════════════════════════════════════════════════════════
// AppRouter — Hệ thống điều hướng tập trung của toàn bộ app.
//
// NGUYÊN TẮC:
//   - KHÔNG ai được tự thêm route vào main.dart hay bất kỳ Widget nào khác.
//   - MỌI route mới phải khai báo tại đây (thêm hằng tên route + GoRoute).
//   - Dùng context.go('/path') hoặc context.push('/path') để điều hướng,
//     KHÔNG dùng Navigator.push truyền thống.
//
// LUỒNG ĐIỀU HƯỚNG (theo file phân chia việc PRM393_Group3_Backlog.xlsx):
//   - Người dùng chưa đăng nhập → InitialLocation = '/login'
//   - Đăng nhập thành công      → GoRouter Guard tự redirect về '/exams'
//   - Đã đăng nhập, mở app lại  → GoRouter Guard tự redirect về '/exams'
// ════════════════════════════════════════════════════════════════════════════
class AppRouter {
  // ── Hằng định nghĩa tên đường dẫn (dùng khi navigate, tránh hard-code string) ──

  /// Màn hình đăng nhập — màn hình đầu tiên khi chưa có phiên đăng nhập.
  static const String login    = '/login';

  /// Màn hình đăng ký tài khoản mới.
  static const String register = '/register';

  /// Màn hình danh sách đề thi (trang chủ sau khi đăng nhập).
  static const String examList = '/exams';

  /// Màn hình chi tiết một đề thi theo ID.
  /// Dùng: context.go('/exams/123') hoặc context.go(AppRouter.examDetail(123))
  static const String examDetailPath = '/exams/:id';

  /// Màn hình ngân hàng câu hỏi.
  static const String questionBank = '/questions';

  /// Màn hình thông báo.
  static const String notifications = '/notifications';

  /// Màn hình phòng chờ thi.
  static const String waitingRoom = '/waiting-room';

  /// Helper tạo đường dẫn chi tiết đề thi với ID cụ thể.
  static String examDetail(int id) => '/exams/$id';

  // ── Khởi tạo GoRouter chính ─────────────────────────────────────────────
  static final GoRouter router = GoRouter(
    // Màn hình đầu tiên khi mở app: trang Login.
    // GoRouter Guard bên dưới sẽ tự redirect sang /exams nếu đã có token.
    initialLocation: login,

    // Hàm guard: kiểm tra xác thực trước mỗi lần điều hướng.
    redirect: _guardRedirect,

    // Danh sách tất cả các route của app.
    routes: [
      // ── Route: Đăng nhập ─────────────────────────────────────────────────
      // CẬP NHẬT: Kết nối LoginScreen thật
      GoRoute(
        path: login,
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),

      // ── Route: Đăng ký ───────────────────────────────────────────────────
      // TODO: Thành viên phụ trách tính năng Auth sẽ đè màn hình thật vào đây sau.
      GoRoute(
        path: register,
        name: 'register',
        builder: (BuildContext context, GoRouterState state) {
          return const _PlaceholderScreen(
            routeName: 'Register Screen',
            routePath: '/register',
            assignee: 'Thành viên phụ trách: Auth Feature',
          );
        },
      ),

      // ── Route: Danh sách đề thi (trang chủ) ─────────────────────────────
      // CẬP NHẬT: Kết nối ExamListScreen thật
      GoRoute(
        path: examList,
        name: 'examList',
        builder: (BuildContext context, GoRouterState state) {
          return const ExamListScreen();
        },

        // ── Sub-route: Chi tiết đề thi ──────────────────────────────────
        // CẬP NHẬT: Kết nối ExamDetailScreen thật
        routes: [
          GoRoute(
            path: ':id', // Đường dẫn đầy đủ: /exams/:id
            name: 'examDetail',
            builder: (BuildContext context, GoRouterState state) {
              // Lấy examId từ path parameter và chuyển sang kiểu int
              final idStr = state.pathParameters['id'] ?? '0';
              final examId = int.tryParse(idStr) ?? 0;
              return ExamDetailScreen(examId: examId);
            },
          ),
        ],
      ),

      // ── Route: Ngân hàng câu hỏi ──────────────────────────────────────────
      GoRoute(
        path: questionBank,
        name: 'questionBank',
        builder: (BuildContext context, GoRouterState state) {
          return const QuestionListScreen();
        },
      ),

      // ── Route: Thông báo ──────────────────────────────────────────────────
      GoRoute(
        path: notifications,
        name: 'notifications',
        builder: (BuildContext context, GoRouterState state) {
          return const NotificationListScreen();
        },
      ),

      GoRoute(
        path: waitingRoom,
        name: 'waitingRoom',
        builder: (BuildContext context, GoRouterState state) {
          final exam = state.extra as ExamModel;
          return WaitingRoomScreen(exam: exam);
        },
      ),
    ],

    // Callback khi GoRouter gặp lỗi (ví dụ: truy cập route không tồn tại).
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
  ///   - Chưa đăng nhập + cố vào trang cần auth → redirect về /login.
  ///   - Đã đăng nhập + đang ở trang public (login/register) → redirect về /exams.
  ///   - Các trường hợp còn lại → cho đi bình thường (return null).
  static Future<String?> _guardRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    // Kiểm tra trạng thái đăng nhập từ StorageManager.
    final bool isLoggedIn = await StorageManager.isLoggedIn();

    // Xác định route hiện tại có phải trang public không (không cần auth).
    final bool isPublicRoute =
        state.matchedLocation == login ||
        state.matchedLocation == register;

    // Chưa đăng nhập và cố vào trang cần auth → về Login.
    if (!isLoggedIn && !isPublicRoute) {
      return login;
    }

    // Đã đăng nhập và đang ở trang public → vào thẳng trang chủ.
    if (isLoggedIn && isPublicRoute) {
      return examList;
    }

    // Mọi trường hợp còn lại → điều hướng bình thường.
    return null;
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _PlaceholderScreen — Màn hình tạm thời, tối giản để dự án compile được.
//
// Mục đích:
//   - Giữ cho app không bị lỗi compile trong khi các thành viên chưa code xong UI.
//   - Hiển thị thông tin route để dễ nhận biết đang ở màn hình nào khi test.
//
// Thành viên phụ trách tính năng sẽ XÓA class này khỏi import và
// THAY THẾ builder trong GoRoute bằng màn hình thật của mình.
// ════════════════════════════════════════════════════════════════════════════
class _PlaceholderScreen extends StatelessWidget {
  /// Tên màn hình (để hiển thị cho dễ nhận biết).
  final String routeName;

  /// Đường dẫn route (để debug).
  final String routePath;

  /// Thành viên phụ trách implement màn hình này.
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
        backgroundColor: Colors.indigo,
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
                color: Colors.indigo,
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
