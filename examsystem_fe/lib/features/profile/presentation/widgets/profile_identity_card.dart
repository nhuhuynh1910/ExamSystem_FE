import 'package:flutter/material.dart';

import '../../models/profile_response.dart';

/// Identity Card pixel-perfect theo HTML:
/// - Card rounded-xl, shadow, border
/// - Full Name (headline)
/// - Email (small gray)
/// - Role badge (border primary, rounded-full)
class ProfileIdentityCard extends StatelessWidget {
  final ProfileResponse profile;
  final VoidCallback? onEditName;

  const ProfileIdentityCard({
    super.key,
    required this.profile,
    this.onEditName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          // Full Name (tappable to edit)
          GestureDetector(
            onTap: onEditName,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    profile.fullName,
                    style: const TextStyle(
                      color: Color(0xFF1D3557),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onEditName != null) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Color(0xFF8E7067),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Email
          Text(
            profile.email,
            style: const TextStyle(
              color: Color(0xFF5A4139),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: const Color(0xFFF15A22),
                width: 1.5,
              ),
            ),
            child: Text(
              '${profile.roleEmoji} ${profile.role}',
              style: const TextStyle(
                color: Color(0xFFF15A22),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
