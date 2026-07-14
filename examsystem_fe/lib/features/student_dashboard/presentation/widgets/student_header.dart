import 'package:flutter/material.dart';

/// Student Header — Header cam FPT, layout giống Teacher Dashboard.
///
/// Hiển thị logo + "Hello, [tên SV] 👋" bên trái + icon notification + badge bên phải.
class StudentHeader extends StatelessWidget {
  final String studentName;
  final int notificationCount;

  const StudentHeader({
    super.key,
    required this.studentName,
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
          // Logo + Tên SV (bên trái — giống Teacher Dashboard)
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
                    'Hello, $studentName 👋',
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
          GestureDetector(
            onTap: () {
              // TODO: Navigate to notifications screen
            },
            child: Stack(
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
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFF15A22),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          notificationCount > 9 ? '9+' : '$notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
