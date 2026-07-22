import '../models/change_password_request.dart';
import '../models/profile_response.dart';
import '../models/update_profile_request.dart';

// ════════════════════════════════════════════════════════════════════════════
// ProfileRepository — Hợp đồng nghiệp vụ (Interface) cho tính năng Profile.
//
// Nằm ở tầng Domain, không phụ thuộc vào thư viện bên thứ 3 (như Dio).
// ════════════════════════════════════════════════════════════════════════════
abstract class ProfileRepository {
  /// Lấy thông tin profile từ BE: GET /api/profile
  Future<ProfileResponse> getProfile();

  /// Cập nhật thông tin profile: PUT /api/profile
  Future<ProfileResponse> updateProfile(UpdateProfileRequest request);

  /// Đổi mật khẩu: POST /api/profile/change-password
  Future<String> changePassword(ChangePasswordRequest request);

  /// Upload avatar: POST /api/profile/avatar
  Future<ProfileResponse> uploadAvatar(List<int> fileBytes, String fileName);
}
