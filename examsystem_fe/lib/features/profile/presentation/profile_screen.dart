import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/routes/app_router.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../models/change_password_request.dart';
import '../models/profile_response.dart';
import '../models/update_profile_request.dart';
import 'widgets/change_password_dialog.dart';
import 'widgets/edit_profile_dialog.dart';
import 'widgets/profile_account_info_card.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/profile_footer.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_identity_card.dart';
import 'widgets/profile_menu_card.dart';
import 'widgets/profile_menu_config.dart';
import 'widgets/profile_sign_out_card.dart';

// ════════════════════════════════════════════════════════════════════════════
// ProfileScreen — Màn hình Profile chính.
//
// UI pixel-perfect theo HTML reference:
//   Header → Avatar → Identity Card → Account Info → Menu → Sign Out → Footer
//
// BlocConsumer cho ProfileBloc + BlocListener cho AuthBloc (logout).
// ════════════════════════════════════════════════════════════════════════════
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        // Khi logout thành công → redirect về onboarding
        if (authState is AuthInitial) {
          context.go(AppRouter.onboarding);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: _onProfileStateChanged,
          builder: (context, state) {
            if (state is ProfileLoading) {
              return _buildLoading();
            }
            if (state is ProfileFailure) {
              return _buildError(context, state.message);
            }

            // Lấy profile từ bất kỳ state nào có profile
            final profile = _getProfileFromState(state);
            if (profile == null) {
              return _buildLoading();
            }

            final isUpdating = state is ProfileUpdating;

            return Stack(
              children: [
                _buildContent(context, profile),
                if (isUpdating) _buildUpdatingOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Xử lý state changes — hiển thị Snackbar.
  void _onProfileStateChanged(BuildContext context, ProfileState state) {
    if (state is ProfileUpdateSuccess) {
      _showSnackBar(context, state.message, isError: false);
    } else if (state is ProfileUpdateFailure) {
      _showSnackBar(context, state.message, isError: true);
    } else if (state is PasswordChangeSuccess) {
      _showSnackBar(context, state.message, isError: false);
    } else if (state is PasswordChangeFailure) {
      _showSnackBar(context, state.message, isError: true);
    }
  }

  /// Main content — scrollable body.
  Widget _buildContent(BuildContext context, ProfileResponse profile) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header + Avatar (overlapping)
          _buildHeaderWithAvatar(context, profile),

          const SizedBox(height: 50),

          // Identity Card
          ProfileIdentityCard(
            profile: profile,
            onEditName: () => _showEditNameDialog(context, profile),
          ),

          const SizedBox(height: 16),

          // Account Information Card
          ProfileAccountInfoCard(profile: profile),

          const SizedBox(height: 16),

          // Menu Card (dynamic theo role)
          _buildMenuCard(context, profile),

          const SizedBox(height: 16),

          // Sign Out Card
          ProfileSignOutCard(
            onSignOut: () => _showLogoutConfirmation(context),
          ),

          // Footer
          const ProfileFooter(),

          // Bottom padding (cho bottom navigation)
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  /// Header + Avatar overlapping via Stack.
  Widget _buildHeaderWithAvatar(BuildContext context, ProfileResponse profile) {
    return SizedBox(
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Gradient Header
          const ProfileHeader(),

          // Avatar (positioned overlapping bottom of header)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: ProfileAvatar(
                imageUrl: profile.profileImageUrl,
                onCameraTap: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null && context.mounted) {
                    final bytes = await pickedFile.readAsBytes();
                    context.read<ProfileBloc>().add(AvatarUploadRequested(bytes, pickedFile.name));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Menu Card — xây dựng từ ProfileMenuConfigBuilder (ViewModel pattern).
  Widget _buildMenuCard(BuildContext context, ProfileResponse profile) {
    final menuConfig = ProfileMenuConfigBuilder(
      profile: profile,
      onNotificationSettings: () {
        // TODO: Navigate to notification settings
        _showSnackBar(context, 'Coming soon!', isError: false);
      },
      onChangePassword: () => _showChangePasswordDialog(context, profile),
      onMySubjects: () {
        // TODO: Navigate to my subjects
        _showSnackBar(context, 'Coming soon!', isError: false);
      },
      onTeacherRequest: () {
        // TODO: Navigate to teacher request
        _showSnackBar(context, 'Coming soon!', isError: false);
      },
      onTeachingSubjects: () {
        // TODO: Navigate to teaching subjects
        _showSnackBar(context, 'Coming soon!', isError: false);
      },
      onQuestionBank: () {
        // TODO: Navigate to question bank
        _showSnackBar(context, 'Coming soon!', isError: false);
      },
      onExamManagement: () {
        // TODO: Navigate to exam management
        _showSnackBar(context, 'Coming soon!', isError: false);
      },
      onHelpSupport: () {
        // TODO: Navigate to help & support
        _showSnackBar(context, 'Coming soon!', isError: false);
      },
    );

    return ProfileMenuCard(menuItems: menuConfig.build());
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showEditNameDialog(BuildContext context, ProfileResponse profile) {
    showDialog(
      context: context,
      builder: (dialogContext) => EditProfileDialog(
        currentName: profile.fullName,
        onSubmit: (newName) {
          context.read<ProfileBloc>().add(
                ProfileUpdateRequested(
                  UpdateProfileRequest(fullName: newName),
                ),
              );
        },
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, ProfileResponse profile) {
    showDialog(
      context: context,
      builder: (dialogContext) => ChangePasswordDialog(
        hasExistingPassword: profile.hasPassword,
        onSubmit: (oldPassword, newPassword, confirmPassword) {
          context.read<ProfileBloc>().add(
                PasswordChangeRequested(
                  ChangePasswordRequest(
                    oldPassword: oldPassword,
                    newPassword: newPassword,
                    confirmPassword: confirmPassword,
                  ),
                ),
              );
        },
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            color: Color(0xFF1D3557),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Color(0xFF5A4139)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF5A4139)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Tái sử dụng LogoutRequested từ AuthBloc hiện tại
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  // ── Loading / Error / Overlay ──────────────────────────────────────────────

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFFF15A22),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFBA1A1A),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF5A4139),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProfileBloc>().add(const ProfileLoadRequested());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF15A22),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdatingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black12,
        child: const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(
                color: Color(0xFFF15A22),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  ProfileResponse? _getProfileFromState(ProfileState state) {
    if (state is ProfileLoaded) return state.profile;
    if (state is ProfileUpdating) return state.profile;
    if (state is ProfileUpdateSuccess) return state.profile;
    if (state is ProfileUpdateFailure) return state.profile;
    if (state is PasswordChangeSuccess) return state.profile;
    if (state is PasswordChangeFailure) return state.profile;
    return null;
  }

  void _showSnackBar(BuildContext context, String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? const Color(0xFFBA1A1A) : const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
