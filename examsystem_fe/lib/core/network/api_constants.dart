/// ════════════════════════════════════════════════════════════════════════════
/// ApiConstants — Tập trung toàn bộ đường dẫn endpoint của BE.
///
/// NGUYÊN TẮC:
///   - KHÔNG ai được tự gõ URL endpoint rải rác trong code.
///   - Mọi thành viên đều dùng hằng số từ class này.
///   - Khi BE thay đổi đường dẫn, chỉ cần sửa đúng 1 chỗ tại đây.
///
/// CẤU TRÚC URL BE:
///   Base: https://<host>:7004/api   (DioClient tự xử lý theo nền tảng)
///   Path: Tất cả hằng bên dưới đều bắt đầu bằng '/' và KHÔNG có '/api' ở đầu.
///   Ví dụ: baseUrl + '/auth/login' = 'https://10.0.2.2:7004/api/auth/login'
///
///   Quy tắc đặt đường dẫn đồng bộ với BE (xem Controllers/*.cs):
///     - AuthController    → [Route("api/[controller]")] → /auth
///     - ExamsController   → [Route("api/exams")]        → /exams
///     - SubjectsController → [Route("api/[controller]")] → /subjects
///     - ProfileController → [Route("api/[controller]")] → /profile
///     - QuestionController → [Route("api/[controller]")] → /question
///
/// LƯU Ý về baseUrl:
///   Hằng baseUrl bên dưới chỉ là giá trị FALLBACK (localhost).
///   DioClient._resolveBaseUrl() sẽ TỰ ĐỘNG chọn đúng URL theo nền tảng:
///     - Android Emulator → https://10.0.2.2:5122/api
///     - iOS/macOS/Web/Windows → https://localhost:5122/api
///   Không cần sửa baseUrl khi chuyển nền tảng.
/// ════════════════════════════════════════════════════════════════════════════
class ApiConstants {
  // ─── Base URL (chỉ dùng làm fallback, DioClient override theo nền tảng) ────
  static const String baseUrl = 'http://localhost:5122/api';

  // ─── Auth (/api/auth/...) ────────────────────────────────────────────────────
  // Đồng bộ với: Controllers/AuthController.cs → [Route("api/[controller]")]
  static const String register           = '/auth/register';             // POST
  static const String login              = '/auth/login';                // POST
  static const String logout             = '/auth/logout';               // POST
  static const String refreshToken       = '/auth/refresh-token';       // POST
  static const String verifyEmail        = '/auth/verify-email';        // GET
  static const String resendVerification = '/auth/resend-verification-email'; // POST
  static const String googleLogin        = '/auth/google-login';        // POST
  static const String forgotPassword     = '/auth/forgot-password';     // POST
  static const String resetPassword      = '/auth/reset-password';      // POST

  // ─── Profile (/api/profile) ───────────────────────────────────────────────────
  // Đồng bộ với: Controllers/ProfileController.cs
  static const String profile        = '/profile';                 // GET / PUT
  static const String profileAvatar   = '/profile/avatar';          // POST
  static const String changePassword  = '/profile/change-password'; // POST

  // ─── Exams (/api/exams/...) ───────────────────────────────────────────────────
  // Đồng bộ với: Controllers/ExamsController.cs → [Route("api/exams")]
  static const String exams        = '/exams';         // GET (list), POST (create)
  static const String teacherExams = '/teacher/exams'; // GET (teacher only)
  
  static String examById(int id) => '/exams/$id';
  static String examCheckAccess(int id) => '/exams/$id/check-access';
  static String examStart(int id) => '/exams/$id/start';
  static String examQuestions(int id) => '/exams/$id/questions';
  static String examResult(int id) => '/exams/$id/result';

  // ─── Attempts (/api/attempts/...) ───────────────────────────────────────────
  static String attemptDetails(int id) => '/attempts/$id';
  static String attemptAnswers(int id) => '/attempts/$id/answers';
  static String attemptSubmit(int id) => '/attempts/$id/submit';

  // ─── Subjects (/api/subjects/...) ────────────────────────────────────────────
  // Đồng bộ với: Controllers/SubjectsController.cs
  static const String subjects = '/subjects'; // GET, POST, PUT, DELETE
  static const String teacherSubjects = '/teacher-requests/my-requests'; // Sửa lại thành /teacher-requests/my-requests

  // ─── Questions (/api/questions/...) ──────────────────────────────────────────
  // Đồng bộ với: Controllers/QuestionController.cs → [Route("api/questions")]
  static const String questions = '/questions'; // GET, POST, PUT, DELETE

  // ─── Users / Roles ───────────────────────────────────────────────────────────
  // Đồng bộ với: Controllers/UsersController.cs, Controllers/RolesController.cs
  static const String users = '/users'; // GET, PUT
  static const String roles = '/roles'; // GET

  // ─── Notifications (/api/notifications/...) ───────────────────────────────────
  // Đồng bộ với: Controllers/BaoNotificationController.cs → [Route("api/notifications")]
  static const String notifications = '/notifications'; // GET, PUT (mark read)

  // ─── Teacher Requests (/api/teacher-requests/...) ────────────────────────────
  // Đồng bộ với: Controllers/BaoTecherRequestController.cs (dùng [HttpPost] full path)
  static const String teacherRequests              = '/teacher-requests';                   // POST (tạo request)
  static const String teacherRequestsAvailSubs     = '/teacher-requests/available-subjects'; // GET
  static const String teacherRequestsMy            = '/teacher-requests/my-requests';       // GET
  // Admin endpoints:
  static const String adminTeacherRequests         = '/admin/teacher-requests';             // GET (danh sách)
  static const String adminTeacherRequestsApprove  = '/admin/teacher-requests/{id}/approve'; // PUT
  static const String adminTeacherRequestsReject   = '/admin/teacher-requests/{id}/reject';  // PUT

  // ─── SignalR Hub ──────────────────────────────────────────────────────────────
  // Đồng bộ với: Program.cs → app.MapHub<BaoNotificationHub>("/hubs/bao-notifications")
  // Dùng để kết nối WebSocket realtime — KHÔNG phải REST API.
  static const String signalrNotificationsHub = '/hubs/bao-notifications';
}
