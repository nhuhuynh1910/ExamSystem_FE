import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/storage_manager.dart';

class StudentBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const StudentBottomNavBar({super.key, required this.currentIndex});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await StorageManager.clearAll();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppTheme.border, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                index: 0,
                icon: Icons.home_rounded,
                label: 'Home',
                route: '/student/dashboard',
              ),
              _buildNavItem(
                context,
                index: 1,
                icon: Icons.assignment_rounded,
                label: 'Catalog',
                route: '/student/courses/catalog',
              ),
              _buildNavItem(
                context,
                index: 2,
                icon: Icons.fact_check_rounded,
                label: 'Registered',
                route: '/student/courses/registered',
              ),
              _buildNavItem(
                context,
                index: 3,
                icon: Icons.logout_rounded,
                label: 'Logout',
                route: '',
                isLogout: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required String route,
    bool isLogout = false,
  }) {
    final isSelected = index == currentIndex;
    final activeColor = AppTheme.primary;
    const inactiveColor = Colors.grey;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (isLogout) {
            _logout(context);
          } else if (!isSelected) {
            context.go(route);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active line indicator
            Container(
              width: 32,
              height: 3,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(
              icon,
              color: isSelected ? activeColor : (isLogout ? AppTheme.error.withOpacity(0.7) : inactiveColor),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : (isLogout ? AppTheme.error.withOpacity(0.7) : inactiveColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
