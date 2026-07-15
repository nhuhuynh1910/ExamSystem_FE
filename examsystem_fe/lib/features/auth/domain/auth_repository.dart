import '../models/auth_response.dart';
import '../models/forgot_password_request.dart';
import '../models/google_login_request.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/reset_password_request.dart';

// ════════════════════════════════════════════════════════════════════════════
// AuthRepository — Hợp đồng nghiệp vụ (Interface) cho tính năng Xác thực.
//
// Nằm ở tầng Domain, không phụ thuộc vào thư viện bên thứ 3 (như Dio).
// ════════════════════════════════════════════════════════════════════════════
abstract class AuthRepository {
  /// Thực hiện đăng nhập tài khoản.
  ///
  /// Trả về [AuthResponse] chứa thông tin user và cặp token JWT.
  Future<AuthResponse> login(LoginRequest request);

  /// Đăng ký tài khoản mới.
  ///
  /// Trả về message thành công từ BE:
  ///   "Đăng ký thành công. Vui lòng kiểm tra email để xác nhận tài khoản."
  ///
  /// Bắn ra [Exception] nếu email/username trùng hoặc lỗi server.
  Future<String> register(RegisterRequest request);

  /// Thực hiện đăng xuất tài khoản trên máy chủ.
  Future<void> logout(String refreshToken);

  /// Đăng nhập bằng Google (gửi idToken lên BE để verify).
  ///
  /// Trả về [AuthResponse] chứa JWT nếu BE verify thành công.
  /// Bắn ra [Exception] nếu idToken không hợp lệ hoặc lỗi server.
  Future<AuthResponse> googleLogin(GoogleLoginRequest request);

  /// Gửi yêu cầu quên mật khẩu.
  ///
  /// BE luôn trả về message thành công (email enumeration protection).
  Future<String> forgotPassword(ForgotPasswordRequest request);

  /// Đặt lại mật khẩu bằng token từ email.
  ///
  /// Bắn ra [Exception] nếu token không hợp lệ hoặc hết hạn.
  Future<String> resetPassword(ResetPasswordRequest request);
}
