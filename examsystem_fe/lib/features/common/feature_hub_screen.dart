import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class FeatureHubScreen extends StatelessWidget {
  const FeatureHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _FeatureItem(
        title: 'Quản trị môn học',
        subtitle: 'Tạo, sửa, xem chi tiết, xóa môn học và gán giáo viên',
        icon: Icons.school_rounded,
        color: AppTheme.primary,
        route: '/admin/courses',
      ),
      _FeatureItem(
        title: 'Sinh viên đăng ký môn',
        subtitle: 'Xem catalog, enroll và unenroll môn học',
        icon: Icons.library_add_check_rounded,
        color: AppTheme.success,
        route: '/student/courses/catalog',
      ),
      _FeatureItem(
        title: 'Sinh viên đã đăng ký',
        subtitle: 'Xem danh sách môn đã enroll và rút khỏi môn',
        icon: Icons.fact_check_rounded,
        color: AppTheme.warning,
        route: '/student/courses/registered',
      ),
      _FeatureItem(
        title: 'Giảng viên quản lý lớp',
        subtitle: 'Xem môn được phân công và danh sách sinh viên',
        icon: Icons.groups_rounded,
        color: AppTheme.secondary,
        route: '/teacher/courses',
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('ExamSystem Feature Hub'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.navy,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final item = items[index];
          return InkWell(
            onTap: () => context.go(item.route),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(item.icon, color: item.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.textMuted),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}
