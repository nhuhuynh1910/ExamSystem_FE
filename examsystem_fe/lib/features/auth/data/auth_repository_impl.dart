import 'package:dio/dio.dart';

import '../domain/auth_repository.dart';
import '../models/auth_response.dart';
import '../models/forgot_password_request.dart';
import '../models/google_login_request.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/reset_password_request.dart';
import 'auth_remote_data_source.dart';

// ════════════════════════════════════════════════════════════════════════════
// AuthRepositoryImpl — Hiện thực hóa AuthRepository.
//
// Nằm ở tầng Data, gọi DataSource và xử lý lỗi kỹ thuật (DioException)
// thành thông điệp tường minh cho tầng nghiệp vụ (BLoC/UI).
// ════════════════════════════════════════════════════════════════════════════
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource();

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      return await _remoteDataSource.login(request);
    } on DioException catch (e) {
      // ── Xử lý lỗi trả về từ Backend ───────────────────────────────────────
      // Backend định dạng lỗi dưới dạng JSON: { "message": "Nội dung lỗi" }
      // (Xem AuthController.cs → return BadRequest/Unauthorized/...)
      if (e.response != null && e.response!.data is Map) {
        final message = e.response!.data['message'] as String?;
        if (message != null && message.isNotEmpty) {
          throw Exception(message);
        }
      }
      
      // Lỗi kết nối, timeout hoặc lỗi không xác định
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<String> register(RegisterRequest request) async {
    try {
      return await _remoteDataSource.register(request);
    } on DioException catch (e) {
      final response = e.response;
      if (response != null && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final message = data['message'] as String?;

        // Trường hợp đặc biệt: email đã đăng ký nhưng chưa xác nhận
        // BE trả về: { "message": "...", "requiresEmailVerification": true }
        final requiresVerification = data['requiresEmailVerification'] as bool? ?? false;
        if (requiresVerification) {
          throw Exception('EMAIL_NOT_VERIFIED:${message ?? ''}')
          ;
        }

        if (message != null && message.isNotEmpty) {
          throw Exception(message);
        }
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await _remoteDataSource.logout(refreshToken);
    } on DioException catch (e) {
      final response = e.response;
      if (response != null && response.data is Map) {
        final message = response.data['message'] as String?;
        if (message != null && message.isNotEmpty) {
          throw Exception(message);
        }
      }
      throw Exception('Không thể kết nối đến máy chủ để đăng xuất.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi khi đăng xuất: $e');
    }
  }

  @override
  Future<AuthResponse> googleLogin(GoogleLoginRequest request) async {
    try {
      return await _remoteDataSource.googleLogin(request);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final message = e.response!.data['message'] as String?;
        if (message != null && message.isNotEmpty) {
          throw Exception(message);
        }
      }

      // Lỗi 404 — BE chưa implement endpoint google-login
      if (e.response?.statusCode == 404) {
        throw Exception(
          'Chức năng đăng nhập bằng Google đang được phát triển. '
          'Vui lòng đăng nhập bằng email/password.',
        );
      }

      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> forgotPassword(ForgotPasswordRequest request) async {
    try {
      return await _remoteDataSource.forgotPassword(request);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final message = e.response!.data['message'] as String?;
        if (message != null && message.isNotEmpty) {
          throw Exception(message);
        }
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> resetPassword(ResetPasswordRequest request) async {
    try {
      return await _remoteDataSource.resetPassword(request);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final message = e.response!.data['message'] as String?;
        if (message != null && message.isNotEmpty) {
          throw Exception(message);
        }
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      rethrow;
    }
  }
}
