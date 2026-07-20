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
        // Base URL động:
        //   - Android Emulator dùng 10.0.2.2 để trỏ về localhost của máy host.
        //   - iOS Simulator / Web / Desktop dùng localhost trực tiếp.
        baseUrl: _resolveBaseUrl(),

        // Timeout kết nối: 15 giây.
        connectTimeout: const Duration(seconds: 15),

        // Timeout nhận dữ liệu: 30 giây (cho phép upload/download file lớn hơn).
        receiveTimeout: const Duration(seconds: 30),

        // Header mặc định cho mọi request JSON.
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Thêm các interceptor theo thứ tự:
    // 1. Interceptor xác thực (gắn token + tự động refresh).
    dio.interceptors.add(_buildAuthInterceptor(dio));

    // 2. LogInterceptor: chỉ bật trong debug mode để không làm lộ thông tin nhạy cảm ở production.
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

      // Bỏ qua chứng chỉ SSL cho Localhost/Emulator (chỉ bật trong Debug mode và KHÔNG phải Web)
      if (!kIsWeb) {
        dio.httpClientAdapter = IOHttpClientAdapter(
          createHttpClient: () {
            final client = HttpClient();
            client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
            return client;
          },
        );
      }
    }

    return dio;
  }

  // ── Xác định Base URL theo nền tảng ───────────────────────────────────────
  static String _resolveBaseUrl() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5122/api';
    }
    return 'http://localhost:5122/api';
  }

  // ── Xây dựng Interceptor xác thực ─────────────────────────────────────────
  static InterceptorsWrapper _buildAuthInterceptor(Dio dio) {
    return InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
        final accessToken = await StorageManager.getAccessToken();
        if (accessToken != null && accessToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        if (error.response?.statusCode == 401) {
          debugPrint('[DioClient] Nhận 401 — thử refresh token...');
          final refreshToken = await StorageManager.getRefreshToken();

          if (refreshToken == null || refreshToken.isEmpty) {
            debugPrint('[DioClient] Không có refreshToken — yêu cầu đăng nhập lại.');
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

            final String newAccessToken  = refreshResponse.data['accessToken']  as String? ?? '';
            final String newRefreshToken = refreshResponse.data['refreshToken'] as String? ?? '';

            if (newAccessToken.isEmpty || newRefreshToken.isEmpty) {
              throw DioException(requestOptions: refreshResponse.requestOptions);
            }

            await StorageManager.saveTokens(
              accessToken:  newAccessToken,
              refreshToken: newRefreshToken,
            );

            debugPrint('[DioClient] Refresh token thành công — retry request gốc.');
            error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await dio.fetch(error.requestOptions);
            return handler.resolve(retryResponse);
          } on DioException catch (retryOrRefreshError) {
            if (retryOrRefreshError.requestOptions.path == ApiConstants.refreshToken) {
              debugPrint('[DioClient] Refresh token thất bại — forced logout.');
              await StorageManager.clearAll();
              return handler.next(error);
            }
            return handler.next(retryOrRefreshError);
          } catch (e) {
            await StorageManager.clearAll();
            return handler.next(error);
          }
        }

        return handler.next(error);
      },
    );
  }
}
