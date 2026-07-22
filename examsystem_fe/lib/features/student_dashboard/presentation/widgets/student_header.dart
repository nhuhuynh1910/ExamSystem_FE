import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../notification/data/notification_api.dart';

/// Student Header — Header cam FPT, kết nối API thông báo thực tế.
class StudentHeader extends StatefulWidget {
  final String studentName;
  final int? notificationCount;

  const StudentHeader({
    super.key,
    required this.studentName,
    this.notificationCount,
  });

  @override
  State<StudentHeader> createState() => _StudentHeaderState();
}

class _StudentHeaderState extends State<StudentHeader> {
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
    } catch (_) {}
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
          // Logo + Tên SV
          Expanded(
            child: Row(
              children: [
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
                    'Hello, ${widget.studentName} 👋',
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
          // Notification bell + badge — Nút gọi API thực tế
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
                        color: Color(0xFFBA1A1A),
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
