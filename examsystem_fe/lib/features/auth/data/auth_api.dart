import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/login_request.dart';
import '../models/auth_response.dart';

class AuthApi {
  final Dio _dio = DioClient.instance;

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data);
  }
}
