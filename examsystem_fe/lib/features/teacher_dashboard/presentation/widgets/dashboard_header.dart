import 'package:flutter/material.dart';

/// Header cam FPT — fixed trên top.
///
/// Hiển thị logo + "Hello, [tên GV] 👋" + icon notification + badge.
class DashboardHeader extends StatelessWidget {
  final String teacherName;
  final int notificationCount;

  const DashboardHeader({
    super.key,
    required this.teacherName,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
      decoration: const BoxDecoration(
        color: Color(0xFFF15A22), // FPT Orange
      ),
      child: Row(
        children: [
          // Logo + Tên GV
          Expanded(
            child: Row(
              children: [
                // Logo FPT tròn nhỏ
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.school_rounded,
                      color: Color(0xFFF15A22),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Hello, Teacher $teacherName 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Notification bell + badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 24,
              ),
              if (notificationCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFFBA1A1A), // error color
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        notificationCount > 9 ? '9+' : '$notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
