import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../notification/data/notification_api.dart';

/// Header cam FPT — fixed trên top cho Teacher.
///
/// Hiển thị logo + "Hello, [tên GV] 👋" + icon notification gọi API thực tế.
class DashboardHeader extends StatefulWidget {
  final String teacherName;
  final int? notificationCount;

  const DashboardHeader({
    super.key,
    required this.teacherName,
    this.notificationCount,
  });

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.notificationCount != null) {
      _unreadCount = widget.notificationCount!;
    }
    _fetchUnreadCount();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final list = await NotificationApi().getNotifications();
      final unread = list.where((n) => !n.isRead).length;
      if (mounted) {
        setState(() {
          _unreadCount = unread;
        });
      }
    } catch (_) {
      // Fallback nếu API trống hoặc chưa sẵn sàng
    }
  }

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
                    'Hello, Teacher ${widget.teacherName} 👋',
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
          // Notification bell icon — Bấm vào chuyển sang trang Thông báo thực tế gọi API
          GestureDetector(
            onTap: () async {
              await context.push(AppRouter.notifications);
              _fetchUnreadCount();
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 26,
                ),
                if (_unreadCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFFBA1A1A), // error red
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _unreadCount > 9 ? '9+' : '$_unreadCount',
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
          ),
        ],
      ),
    );
  }
}
