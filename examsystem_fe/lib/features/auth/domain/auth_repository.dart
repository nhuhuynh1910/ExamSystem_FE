import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

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
}

