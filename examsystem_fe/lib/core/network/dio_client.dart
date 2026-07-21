import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../utils/storage_manager.dart';
import 'api_constants.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// DioClient — HTTP client dùng chung cho toàn bộ app.
/// ════════════════════════════════════════════════════════════════════════════
class DioClient {
  static Dio? _dio;

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static void resetInstance() {
    _dio = null;
  }

  // ── Tạo và cấu hình instance Dio ──────────────────────────────────────────
  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _resolveBaseUrl(),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptors
    dio.interceptors.add(_buildAuthInterceptor(dio));

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: false,
          responseHeader: true,
          responseBody: false,
          error: true,
          logPrint: (object) => debugPrint('[DioClient] $object'),
        ),
      );

      if (!kIsWeb) {
        dio.httpClientAdapter = IOHttpClientAdapter(
          createHttpClient: () {
            final client = HttpClient();
            client.badCertificateCallback =
                (X509Certificate cert, String host, int port) => true;
            return client;
          },
        );
      }
    }

    return dio;
  }

  static String _resolveBaseUrl() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5122/api';
    }
    return 'http://localhost:5122/api';
  }

  static InterceptorsWrapper _buildAuthInterceptor(Dio dio) {
    return InterceptorsWrapper(
      onRequest:
          (RequestOptions options, RequestInterceptorHandler handler) async {
        final accessToken = await StorageManager.getAccessToken();
        if (accessToken != null && accessToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        if (error.response?.statusCode == 401) {
          // Nếu chính API /auth/refresh-token bị 401 thì mới xóa token và logout
          if (error.requestOptions.path.contains(ApiConstants.refreshToken)) {
            debugPrint(
                '[DioClient] Endpoint refresh token bị 401 — thực hiện logout.');
            await StorageManager.clearAll();
            return handler.next(error);
          }

          debugPrint('[DioClient] Nhận 401 — thử refresh token...');
          final refreshToken = await StorageManager.getRefreshToken();

          if (refreshToken == null || refreshToken.isEmpty) {
            debugPrint(
                '[DioClient] Không có refreshToken — yêu cầu đăng nhập lại.');
            await StorageManager.clearAll();
            return handler.next(error);
          }

          try {
            final refreshDio = Dio(
              BaseOptions(
                baseUrl: _resolveBaseUrl(),
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

            final refreshResponse = await refreshDio.post(
              ApiConstants.refreshToken,
              data: {'refreshToken': refreshToken},
            );

            final String newAccessToken =
                refreshResponse.data['accessToken'] as String? ?? '';
            final String newRefreshToken =
                refreshResponse.data['refreshToken'] as String? ?? '';

            if (newAccessToken.isEmpty || newRefreshToken.isEmpty) {
              await StorageManager.clearAll();
              return handler.next(error);
            }

            await StorageManager.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            debugPrint(
                '[DioClient] Refresh token thành công — retry request gốc với Token mới.');
            final options = error.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await dio.fetch(options);
            return handler.resolve(retryResponse);
          } catch (e) {
            debugPrint('[DioClient] Lỗi khi refresh token: $e');
            await StorageManager.clearAll();
            return handler.next(error);
          }
        }

        return handler.next(error);
      },
    );
  }
}
