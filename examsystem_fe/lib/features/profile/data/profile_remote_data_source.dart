import 'package:dio/dio.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/change_password_request.dart';
import '../models/profile_response.dart';
import '../models/update_profile_request.dart';

// ════════════════════════════════════════════════════════════════════════════
// ProfileRemoteDataSource — Nguồn dữ liệu từ xa cho tính năng Profile.
//
// Giao tiếp trực tiếp với Backend .NET thông qua DioClient.
// ════════════════════════════════════════════════════════════════════════════
class ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance;

  /// GET /api/profile
  Future<ProfileResponse> getProfile() async {
    final response = await _dio.get(ApiConstants.profile);
    return ProfileResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// PUT /api/profile (FormData vì BE dùng [FromForm])
  Future<ProfileResponse> updateProfile(UpdateProfileRequest request) async {
    final formData = FormData.fromMap(request.toJson());
    final response = await _dio.put(
      ApiConstants.profile,
      data: formData,
    );
    return ProfileResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /api/profile/change-password
  Future<String> changePassword(ChangePasswordRequest request) async {
    final response = await _dio.post(
      ApiConstants.changePassword,
      data: request.toJson(),
    );
    return (response.data as Map<String, dynamic>)['message'] as String;
  }

  /// POST /api/profile/avatar (multipart upload)
  Future<ProfileResponse> uploadAvatar(List<int> fileBytes, String fileName) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });
    final response = await _dio.post(
      ApiConstants.profileAvatar,
      data: formData,
    );
    return ProfileResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
