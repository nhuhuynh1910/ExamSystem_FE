import '../models/change_password_request.dart';
import '../models/update_profile_request.dart';

// ════════════════════════════════════════════════════════════════════════════
// ProfileEvent — Các sự kiện mà UI gửi vào ProfileBloc.
// ════════════════════════════════════════════════════════════════════════════
abstract class ProfileEvent {
  const ProfileEvent();
}

/// Load profile từ BE.
class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

/// Cập nhật profile (Full Name).
class ProfileUpdateRequested extends ProfileEvent {
  final UpdateProfileRequest request;
  const ProfileUpdateRequested(this.request);
}

/// Đổi mật khẩu.
class PasswordChangeRequested extends ProfileEvent {
  final ChangePasswordRequest request;
  const PasswordChangeRequested(this.request);
}

/// Upload avatar mới.
class AvatarUploadRequested extends ProfileEvent {
  final List<int> fileBytes;
  final String fileName;
  const AvatarUploadRequested(this.fileBytes, this.fileName);
}
