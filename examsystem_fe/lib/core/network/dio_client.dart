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
          // Bật tắt log request/response (tắt body để tránh lỗi OOM trên Windows console)
          request: true,
          requestHeader: true,
          requestBody: false, // <-- Tắt để fix lỗi OOM
          responseHeader: true,
          responseBody: false, // <-- Tắt để fix lỗi OOM
          error: true,
          logPrint: (object) => debugPrint('[DioClient] $object'),
        ),
      );

      dio.interceptors.add(_buildAuthInterceptor(dio));

      // Bỏ qua chứng chỉ SSL cho Localhost/Emulator (chỉ bật trong Debug mode và KHÔNG phải Web)
      if (kDebugMode && !kIsWeb) {
        dio.httpClientAdapter = IOHttpClientAdapter(
          createHttpClient: () {
            final client = HttpClient();
            client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
            return client;
          },
        );
      }

      if (kDebugMode) {
        dio.interceptors.add(
          LogInterceptor(
            request: true,
            requestHeader: true,
            requestBody: true,
            responseHeader: true,
            responseBody: true,
            error: true,
            logPrint: (object) => debugPrint('[DioClient] $object'),
          ),
        );
      }

      return dio;
    }

    return dio;
  }

  // ── Xác định Base URL theo nền tảng ───────────────────────────────────────
  /// BE chạy tại port 5122. Tất cả endpoint đều có tiền tố `/api/`.
  /// Ví dụ:  POST http://10.0.2.2:5122/api/auth/login
  ///         GET  http://10.0.2.2:5122/api/exams
  static String _resolveBaseUrl() {
    // defaultTargetPlatform là Android → đang chạy trên Android Emulator.
    // Android Emulator không thể dùng "localhost" vì nó là localhost của chính emulator.
    // Phải dùng 10.0.2.2 để trỏ về máy host.
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5122/api';
    }

    // iOS Simulator, macOS Desktop, Windows Desktop, Web → dùng localhost.
    return 'http://localhost:5122/api';
  }

  // ── Xây dựng Interceptor xác thực ─────────────────────────────────────────
  /// Interceptor này thực hiện 2 nhiệm vụ:
  ///   A. onRequest  → đọc accessToken từ StorageManager và gắn vào header.
  ///   B. onError    → nếu nhận 401, thử refresh token một lần rồi retry request.
  static InterceptorsWrapper _buildAuthInterceptor(Dio dio) {
    return InterceptorsWrapper(
      // ── A. Trước mỗi request: gắn Bearer token ──────────────────────────
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
        // Đọc accessToken đã lưu trong SharedPreferences thông qua StorageManager.
        final accessToken = await StorageManager.getAccessToken();

        if (accessToken != null && accessToken.isNotEmpty) {
          // Gắn header xác thực theo chuẩn Bearer JWT mà BE yêu cầu.
          // BE kiểm tra: Authorization: Bearer <accessToken>
          options.headers['Authorization'] = 'Bearer $accessToken';
        }

        // Cho phép request tiếp tục.
        return handler.next(options);
      },

      // ── B. Khi nhận lỗi: xử lý 401 Unauthorized ─────────────────────────
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        // Chỉ xử lý lỗi 401 (token hết hạn).
        if (error.response?.statusCode == 401) {
          debugPrint('[DioClient] Nhận 401 — thử refresh token...');

          // Lấy refreshToken từ bộ nhớ cục bộ.
          final refreshToken = await StorageManager.getRefreshToken();

          // Nếu không có refreshToken → không thể làm gì, trả lỗi về.
          if (refreshToken == null || refreshToken.isEmpty) {
            debugPrint('[DioClient] Không có refreshToken — yêu cầu đăng nhập lại.');
            await StorageManager.clearAll(); // Xóa dữ liệu cũ.
            return handler.next(error);
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            debugPrint('[DioClient] Nhận 401 — thử refresh token...');
            final refreshToken = await StorageManager.getRefreshToken();

          String newAccessToken = '';
          String newRefreshToken = '';

          try {
            // Tạo một Dio riêng để gọi API refresh token (không dùng Dio chính
            // để tránh vòng lặp interceptor vô tận).
            final refreshDio = Dio(
              BaseOptions(
                baseUrl: _resolveBaseUrl(),
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

            try {
              final refreshDio = Dio(BaseOptions(baseUrl: _resolveBaseUrl()));
              final refreshResponse = await refreshDio.post(
                ApiConstants.refreshToken,
                data: {'refreshToken': refreshToken},
              );

            // BE trả về JSON dạng camelCase (do .NET mặc định serialize PascalCase → camelCase):
            // { "accessToken": "...", "refreshToken": "..." }
            newAccessToken  = refreshResponse.data['accessToken']  as String? ?? '';
            newRefreshToken = refreshResponse.data['refreshToken'] as String? ?? '';

            if (newAccessToken.isEmpty || newRefreshToken.isEmpty) {
              throw DioException(requestOptions: refreshResponse.requestOptions);
            }

            // Lưu cặp token mới vào bộ nhớ cục bộ.
            await StorageManager.saveTokens(
              accessToken:  newAccessToken,
              refreshToken: newRefreshToken,
            );

            debugPrint('[DioClient] Refresh token thành công — retry request gốc.');
          } on DioException catch (refreshError) {
            // Refresh thất bại (token hết hạn hoặc đã bị thu hồi) → buộc logout.
            debugPrint('[DioClient] Refresh token thất bại: ${refreshError.message}');
            await StorageManager.clearAll(); // Xóa toàn bộ dữ liệu auth.
            return handler.next(error); // Trả lỗi 401 về cho UI xử lý.
          }

          // Cập nhật header của request gốc với token mới.
          error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          // Retry lại request gốc đã thất bại.
          try {
            final retryResponse = await dio.fetch(error.requestOptions);
            return handler.resolve(retryResponse);
          } on DioException catch (retryError) {
            // Trả đúng lỗi từ request retry (ví dụ 400 Mật khẩu hiện tại không đúng)
            // về cho Repository/UI xử lý, không bị nhầm là lỗi refresh token.
            return handler.next(retryError);
          }
        }

        // Với các lỗi khác (400, 403, 404, 500...) → trả thẳng về.
        return handler.next(error);
      },
    );
  }
