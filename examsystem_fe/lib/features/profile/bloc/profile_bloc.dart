import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/profile_repository_impl.dart';
import '../domain/profile_repository.dart';
import '../models/profile_response.dart';
import 'profile_event.dart';
import 'profile_state.dart';

// ════════════════════════════════════════════════════════════════════════════
// ProfileBloc — Quản lý logic nghiệp vụ cho tính năng Profile.
//
// Theo pattern AuthBloc:
//   - Nhận events từ UI
//   - Gọi repository
//   - Emit states tương ứng
// ════════════════════════════════════════════════════════════════════════════
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc({ProfileRepository? profileRepository})
      : _profileRepository = profileRepository ?? ProfileRepositoryImpl(),
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadProfile);
    on<ProfileUpdateRequested>(_onUpdateProfile);
    on<PasswordChangeRequested>(_onChangePassword);
    on<AvatarUploadRequested>(_onUploadAvatar);
  }

  /// Load profile từ BE.
  Future<void> _onLoadProfile(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    try {
      final profile = await _profileRepository.getProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(ProfileFailure(errorMessage));
    }
  }

  /// Cập nhật profile (Full Name).
  Future<void> _onUpdateProfile(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // Giữ profile hiện tại để có thể quay lại nếu lỗi
    final currentProfile = _getCurrentProfile();
    if (currentProfile != null) {
      emit(ProfileUpdating(currentProfile));
    }

    try {
      final updatedProfile = await _profileRepository.updateProfile(event.request);
      emit(ProfileUpdateSuccess(updatedProfile, 'Profile updated successfully!'));
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      if (currentProfile != null) {
        emit(ProfileUpdateFailure(currentProfile, errorMessage));
      } else {
        emit(ProfileFailure(errorMessage));
      }
    }
  }

  /// Đổi mật khẩu.
  Future<void> _onChangePassword(
    PasswordChangeRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentProfile = _getCurrentProfile();
    if (currentProfile != null) {
      emit(ProfileUpdating(currentProfile));
    }

    try {
      final message = await _profileRepository.changePassword(event.request);
      if (currentProfile != null) {
        emit(PasswordChangeSuccess(currentProfile, message));
      }
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      if (currentProfile != null) {
        emit(PasswordChangeFailure(currentProfile, errorMessage));
      } else {
        emit(ProfileFailure(errorMessage));
      }
    }
  }

  /// Upload avatar.
  Future<void> _onUploadAvatar(
    AvatarUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentProfile = _getCurrentProfile();
    if (currentProfile != null) {
      emit(ProfileUpdating(currentProfile));
    }

    try {
      final updatedProfile = await _profileRepository.uploadAvatar(event.fileBytes, event.fileName);
      emit(ProfileUpdateSuccess(updatedProfile, 'Avatar updated successfully!'));
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      if (currentProfile != null) {
        emit(ProfileUpdateFailure(currentProfile, errorMessage));
      } else {
        emit(ProfileFailure(errorMessage));
      }
    }
  }

  /// Helper: lấy profile hiện tại từ state (nếu có).
  ProfileResponse? _getCurrentProfile() {
    final currentState = state;
    if (currentState is ProfileLoaded) return currentState.profile;
    if (currentState is ProfileUpdating) return currentState.profile;
    if (currentState is ProfileUpdateSuccess) return currentState.profile;
    if (currentState is ProfileUpdateFailure) return currentState.profile;
    if (currentState is PasswordChangeSuccess) return currentState.profile;
    if (currentState is PasswordChangeFailure) return currentState.profile;
    return null;
  }
}
