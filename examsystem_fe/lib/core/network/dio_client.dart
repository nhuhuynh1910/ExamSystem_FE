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

    static Dio _createDio() {
      final dio = Dio(
        BaseOptions(
          baseUrl: _resolveBaseUrl(),
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Accept': 'application/json',
          },
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

    static String _resolveBaseUrl() {
      if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
        return 'https://10.0.2.2:7004/api';
      }
      return 'https://localhost:7004/api';
    }

    static InterceptorsWrapper _buildAuthInterceptor(Dio dio) {
      return InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await StorageManager.getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            debugPrint('[DioClient] Nhận 401 — thử refresh token...');
            final refreshToken = await StorageManager.getRefreshToken();

            if (refreshToken == null || refreshToken.isEmpty) {
              await StorageManager.clearAll();
              return handler.next(error);
            }

            try {
              final refreshDio = Dio(BaseOptions(baseUrl: _resolveBaseUrl()));
              final refreshResponse = await refreshDio.post(
                ApiConstants.refreshToken,
                data: {'refreshToken': refreshToken},
              );

              final newAccessToken = refreshResponse.data['accessToken'] as String? ?? '';
              final newRefreshToken = refreshResponse.data['refreshToken'] as String? ?? '';

              await StorageManager.saveTokens(accessToken: newAccessToken, refreshToken: newRefreshToken);
              error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              final retryResponse = await dio.fetch(error.requestOptions);
              return handler.resolve(retryResponse);
            } catch (refreshError) {
              await StorageManager.clearAll();
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      );
    }
  }
