import '../models/profile_response.dart';

// ════════════════════════════════════════════════════════════════════════════
// ProfileState — Các trạng thái của ProfileBloc.
//
// States:
//   Initial → Loading → Loaded (success) hoặc Failure
//   Loaded → Updating → UpdateSuccess / UpdateFailure (quay lại Loaded)
//   Loaded → PasswordChangeSuccess / PasswordChangeFailure (quay lại Loaded)
// ════════════════════════════════════════════════════════════════════════════
abstract class ProfileState {
  const ProfileState();
}

/// Trạng thái ban đầu khi chưa load profile.
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Đang tải profile từ BE.
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Đã tải profile thành công.
class ProfileLoaded extends ProfileState {
  final ProfileResponse profile;
  const ProfileLoaded(this.profile);
}

/// Đang cập nhật profile (update name, change password...).
class ProfileUpdating extends ProfileState {
  final ProfileResponse profile;
  const ProfileUpdating(this.profile);
}

/// Cập nhật profile thành công.
class ProfileUpdateSuccess extends ProfileState {
  final ProfileResponse profile;
  final String message;
  const ProfileUpdateSuccess(this.profile, this.message);
}

/// Cập nhật profile thất bại.
class ProfileUpdateFailure extends ProfileState {
  final ProfileResponse profile;
  final String message;
  const ProfileUpdateFailure(this.profile, this.message);
}

/// Đổi mật khẩu thành công.
class PasswordChangeSuccess extends ProfileState {
  final ProfileResponse profile;
  final String message;
  const PasswordChangeSuccess(this.profile, this.message);
}

/// Đổi mật khẩu thất bại.
class PasswordChangeFailure extends ProfileState {
  final ProfileResponse profile;
  final String message;
  const PasswordChangeFailure(this.profile, this.message);
}

/// Lỗi không tải được profile (network, 401, 500...).
class ProfileFailure extends ProfileState {
  final String message;
  const ProfileFailure(this.message);
}
