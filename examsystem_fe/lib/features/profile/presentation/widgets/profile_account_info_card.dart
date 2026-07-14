import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/profile_response.dart';

/// Account Information Card pixel-perfect theo HTML:
/// - Header: "ACCOUNT INFORMATION" (primary, uppercase, tracking-wider)
/// - Info rows: label (gray, 13px) | value (#1D3557, medium, 14px)
/// - Dynamic rows dựa trên role (Student ID hoặc Teacher ID)
class ProfileAccountInfoCard extends StatelessWidget {
  final ProfileResponse profile;

  const ProfileAccountInfoCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final rows = _buildInfoRows();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'ACCOUNT INFORMATION',
              style: TextStyle(
                color: Color(0xFFF15A22),
                fontWeight: FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.8,
              ),
            ),
          ),
          // Info rows
          ...rows.asMap().entries.map((entry) {
            final isLast = entry.key == rows.length - 1;
            return _InfoRow(
              label: entry.value.$1,
              value: entry.value.$2,
              showDivider: !isLast,
            );
          }),
        ],
      ),
    );
  }

  /// Xây dựng danh sách info rows dựa trên role.
  /// Không dùng if rải rác — tập trung logic tại đây.
  List<(String, String)> _buildInfoRows() {
    final rows = <(String, String)>[];

    // Student ID / Teacher ID (dynamic theo role)
    if (profile.isStudent && profile.studentId != null) {
      rows.add(('Student ID', profile.studentId!));
    } else if (profile.isTeacher && profile.teacherId != null) {
      rows.add(('Teacher ID', profile.teacherId!));
    }

    rows.add(('Full Name', profile.fullName));
    rows.add(('Email', profile.email));

    // Format date
    final joinedDate = DateFormat('MMMM yyyy').format(profile.createdAt);
    rows.add(('Joined', joinedDate));

    return rows;
  }
}

/// Widget cho mỗi row trong Account Information.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _InfoRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF5A4139),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF1D3557),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F5F9),
          ),
      ],
    );
  }
}
