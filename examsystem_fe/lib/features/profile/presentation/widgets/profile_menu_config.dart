import 'package:flutter/material.dart';

import '../../models/profile_response.dart';

/// Cấu hình menu item — ViewModel pattern.
/// Không dùng if rải rác trong UI, tập trung logic tại đây.
class ProfileMenuItemConfig {
  final IconData icon;
  final String label;
  final String? badgeText;
  final VoidCallback? onTap;

  const ProfileMenuItemConfig({
    required this.icon,
    required this.label,
    this.badgeText,
    this.onTap,
  });
}

/// Builder trả về danh sách menu items phù hợp theo role.
///
/// Student: Notification Settings, Change Password, My Subjects, Teacher Request, Help & Support
/// Teacher: Notification Settings, Change Password, Teaching Subjects, Question Bank, Exam Management, Help & Support
class ProfileMenuConfigBuilder {
  final ProfileResponse profile;
  final VoidCallback? onNotificationSettings;
  final VoidCallback? onChangePassword;
  final VoidCallback? onMySubjects;
  final VoidCallback? onTeacherRequest;
  final VoidCallback? onTeachingSubjects;
  final VoidCallback? onQuestionBank;
  final VoidCallback? onExamManagement;
  final VoidCallback? onHelpSupport;

  const ProfileMenuConfigBuilder({
    required this.profile,
    this.onNotificationSettings,
    this.onChangePassword,
    this.onMySubjects,
    this.onTeacherRequest,
    this.onTeachingSubjects,
    this.onQuestionBank,
    this.onExamManagement,
    this.onHelpSupport,
  });

  List<ProfileMenuItemConfig> build() {
    final items = <ProfileMenuItemConfig>[];

    // ── Common items ─────────────────────────────────────────────
    items.add(ProfileMenuItemConfig(
      icon: Icons.notifications_outlined,
      label: 'Notification Settings',
      onTap: onNotificationSettings,
    ));

    items.add(ProfileMenuItemConfig(
      icon: Icons.lock_outline,
      label: 'Change Password',
      onTap: onChangePassword,
    ));

    // ── Role-specific items ──────────────────────────────────────
    if (profile.isStudent) {
      items.add(ProfileMenuItemConfig(
        icon: Icons.menu_book_outlined,
        label: 'My Subjects',
        onTap: onMySubjects,
      ));
      items.add(ProfileMenuItemConfig(
        icon: Icons.person_search_outlined,
        label: 'Teacher Request',
        badgeText: 'PENDING',
        onTap: onTeacherRequest,
      ));
    }

    if (profile.isTeacher) {
      items.add(ProfileMenuItemConfig(
        icon: Icons.menu_book_outlined,
        label: 'Teaching Subjects',
        onTap: onTeachingSubjects,
      ));
      items.add(ProfileMenuItemConfig(
        icon: Icons.quiz_outlined,
        label: 'Question Bank',
        onTap: onQuestionBank,
      ));
      items.add(ProfileMenuItemConfig(
        icon: Icons.assignment_outlined,
        label: 'Exam Management',
        onTap: onExamManagement,
      ));
    }

    // ── Common bottom items ──────────────────────────────────────
    if (!profile.isAdmin) {
      items.add(ProfileMenuItemConfig(
        icon: Icons.help_outline,
        label: 'Help & Support',
        onTap: onHelpSupport,
      ));
    }

    return items;
  }
}
