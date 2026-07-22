import 'package:dio/dio.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/auth_response.dart';
import '../models/forgot_password_request.dart';
import '../models/google_login_request.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/reset_password_request.dart';

// ════════════════════════════════════════════════════════════════════════════
// AuthRemoteDataSource — Nguồn dữ liệu từ xa cho tính năng Xác thực.
//
// Giao tiếp trực tiếp với Backend .NET thông qua DioClient.
// ════════════════════════════════════════════════════════════════════════════
class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance;

  /// Gọi API đăng nhập của Backend: POST /api/auth/login
  ///
  /// Nhận vào `LoginRequest` (emailOrUsername, password)
  /// Trả về `AuthResponse` nếu đăng nhập thành công.
  /// Bắn ra `DioException` nếu Backend trả về lỗi (400, 401, 500...).
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: request.toJson(),
    );

    // Backend trả về JSON object đồng bộ với DTO AuthResponse.cs:
    // { "userId": 1, "fullName": "...", "accessToken": "...", "refreshToken": "..." }
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Gọi API đăng ký tài khoản: POST /api/auth/register
  ///
  /// Backend trả về:
  ///   200 OK → { "message": "Đăng ký thành công..." }
  ///   400 Bad Request → { "message": "Email đã tồn tại." }
  ///   400 Bad Request (cần verify) → { "message": "...", "requiresEmailVerification": true }
  Future<String> register(RegisterRequest request) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: request.toJson(),
    );

    // BE trả về object: { "message": "Đăng ký thành công..." }
    return (response.data as Map<String, dynamic>)['message'] as String;
  }

  /// Gọi API đăng xuất của Backend: POST /api/auth/logout
  ///
  /// Nhận vào `refreshToken` để hủy phiên ở máy chủ.
  Future<void> logout(String refreshToken) async {
    await _dio.post(
      ApiConstants.logout,
      data: {'refreshToken': refreshToken},
    );
  }

  /// Gọi API đăng nhập bằng Google: POST /api/auth/google-login
  ///
  /// Nhận vào `GoogleLoginRequest` (idToken từ Google)
  /// BE sẽ verify idToken → tạo/tìm user → trả `AuthResponse`.
  Future<AuthResponse> googleLogin(GoogleLoginRequest request) async {
    final response = await _dio.post(
      ApiConstants.googleLogin,
      data: request.toJson(),
    );

    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Gọi API quên mật khẩu: POST /api/auth/forgot-password
  ///
  /// BE luôn trả về 200 OK: { "message": "..." } (email enumeration protection).
  Future<String> forgotPassword(ForgotPasswordRequest request) async {
    final response = await _dio.post(
      ApiConstants.forgotPassword,
      data: request.toJson(),
    );

    return (response.data as Map<String, dynamic>)['message'] as String;
  }

  /// Gọi API đặt lại mật khẩu: POST /api/auth/reset-password
  ///
  /// Nhận vào `ResetPasswordRequest` (token + newPassword).
  /// BE trả về:
  ///   200 OK → { "message": "Đặt lại mật khẩu thành công..." }
  ///   400 Bad Request → { "message": "Token không hợp lệ..." }
  Future<String> resetPassword(ResetPasswordRequest request) async {
    final response = await _dio.post(
      ApiConstants.resetPassword,
      data: request.toJson(),
    );

    return (response.data as Map<String, dynamic>)['message'] as String;
  }
}
