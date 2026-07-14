import 'package:dio/dio.dart';

import '../domain/profile_repository.dart';
import '../models/change_password_request.dart';
import '../models/profile_response.dart';
import '../models/update_profile_request.dart';
import 'profile_remote_data_source.dart';

// ════════════════════════════════════════════════════════════════════════════
// ProfileRepositoryImpl — Hiện thực hóa ProfileRepository.
//
// Nằm ở tầng Data, gọi DataSource và xử lý lỗi kỹ thuật (DioException)
// thành thông điệp tường minh cho tầng nghiệp vụ (BLoC/UI).
// Theo pattern AuthRepositoryImpl.
// ════════════════════════════════════════════════════════════════════════════
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl({ProfileRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ProfileRemoteDataSource();

  @override
  Future<ProfileResponse> getProfile() async {
    try {
      return await _remoteDataSource.getProfile();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(
        e,
        'Không thể tải thông tin profile. Vui lòng thử lại sau.',
      ));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProfileResponse> updateProfile(UpdateProfileRequest request) async {
    try {
      return await _remoteDataSource.updateProfile(request);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(
        e,
        'Không thể cập nhật profile. Vui lòng thử lại sau.',
      ));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> changePassword(ChangePasswordRequest request) async {
    try {
      return await _remoteDataSource.changePassword(request);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(
        e,
        'Không thể đổi mật khẩu. Vui lòng thử lại sau.',
      ));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProfileResponse> uploadAvatar(List<int> fileBytes, String fileName) async {
    try {
      return await _remoteDataSource.uploadAvatar(fileBytes, fileName);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(
        e,
        'Không thể upload ảnh đại diện. Vui lòng thử lại sau.',
      ));
    } catch (e) {
      rethrow;
    }
  }

  String _extractErrorMessage(DioException e, String defaultMessage) {
    final response = e.response;
    if (response != null && response.data != null) {
      final data = response.data;
      if (data is Map) {
        final message = data['message'] as String?;
        if (message != null && message.isNotEmpty) {
          return message;
        }
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstEntry = errors.values.first;
          if (firstEntry is List && firstEntry.isNotEmpty) {
            return firstEntry.first.toString();
          }
        }
        final title = data['title'] as String?;
        if (title != null && title.isNotEmpty) {
          return title;
        }
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
    }
    return defaultMessage;
  }
}
