import 'package:flutter/material.dart';

import 'profile_menu_config.dart';
import 'profile_menu_item.dart';

/// Menu Card pixel-perfect theo HTML.
/// Hiển thị danh sách menu items từ ProfileMenuConfigBuilder.
class ProfileMenuCard extends StatelessWidget {
  final List<ProfileMenuItemConfig> menuItems;

  const ProfileMenuCard({
    super.key,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
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
        mainAxisSize: MainAxisSize.min,
        children: menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == menuItems.length - 1;

          return ProfileMenuItem(
            icon: item.icon,
            label: item.label,
            onTap: item.onTap,
            showDivider: !isLast,
            trailing: item.badgeText != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3EE),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          item.badgeText!,
                          style: const TextStyle(
                            color: Color(0xFFF15A22),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Color(0xFF8E7067),
                      ),
                    ],
                  )
                : null,
          );
        }).toList(),
      ),
    );
  }
}
