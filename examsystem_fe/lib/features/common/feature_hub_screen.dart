import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/storage_manager.dart';
import '../../core/network/dio_client.dart';

/// FeatureHubScreen — Trang trung tâm Admin Dashboard.
class FeatureHubScreen extends StatefulWidget {
  const FeatureHubScreen({super.key});

  @override
  State<FeatureHubScreen> createState() => _FeatureHubScreenState();
}

class _FeatureHubScreenState extends State<FeatureHubScreen> {
  String? _fullName;
  String? _role;
  String? _username;

  int _totalStudents = 0;
  int _activeCourses = 0;
  int _facultyMembers = 0;
  int _examsConducted = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final dio = DioClient.instance;

      // 1. Fetch Users
      final usersRes = await dio.get('/users');
      int students = 0;
      int teachers = 0;
      if (usersRes.data is List) {
        final list = usersRes.data as List;
        for (var item in list) {
          final role = item['role']?.toString();
          if (role == 'Student') {
            students++;
          } else if (role == 'Teacher') {
            teachers++;
          }
        }
      }

      // 2. Fetch Subjects
      final subjectsRes = await dio.get('/subjects');
      int courses = 0;
      if (subjectsRes.data is List) {
        courses = (subjectsRes.data as List).length;
      }

      // 3. Fetch Exams
      int exams = 0;
      try {
        final examsRes = await dio.get('/exams');
        if (examsRes.data is List) {
          exams = (examsRes.data as List).length;
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _totalStudents = students;
          _facultyMembers = teachers;
          _activeCourses = courses;
          _examsConducted = exams;
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');
    }
  }

  Future<void> _loadUserInfo() async {
    final fullName = await StorageManager.getFullName();
    final role = await StorageManager.getRole();
    final username = await StorageManager.getUsername();
    if (mounted) {
      setState(() {
        _fullName = fullName ?? 'Người dùng';
        _role = role ?? 'Unknown';
        _username = username ?? '';
      });
    }
  }

  Future<void> _logout() async {
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

    if (confirmed == true && mounted) {
      await StorageManager.clearAll();
      if (mounted) context.go('/login');
    }
  }

  void _showFeaturePendingDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(featureName),
        content: Text('Tính năng "$featureName" đang được phát triển và sẽ sớm ra mắt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      // ── Top App Bar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.primary),
          onPressed: () => _showFeaturePendingDialog(context, 'Menu'),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              'https://lh3.googleusercontent.com/aida/AP1WRLs9uI4gDsk_p6lAI1OqbHDXyKZBdrqeBA-bY4xnIk1CUgoqLvT_0KFZMolYwqah0XQ8B8y5zcmkzSSW6y3731qbMPyW-67cNO6_wYkU0U9d4m65t2DRuN2P389YSNot3Qgpt2xkLrQGShRsIIQ8tEfu1R2x3BYDpsAKOJ9FjtpDRLqnXyPR15zqIJJxnXq_rXCEWeN_DpYjvdpwEbesYOMwglGphQdkDOQze_e7a1ekrgEmmZGg_9Cereg',
              height: 32,
              errorBuilder: (_, __, ___) => const Icon(Icons.school, color: AppTheme.primary),
            ),
            const SizedBox(width: 8),
            const Text(
              'FPT ExamHub',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
            onPressed: _logout,
            tooltip: 'Đăng xuất',
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary, width: 1.5),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDkjuVzVcYsKpzjWu50v7GrxIhms3Ht071Ukj4M0xvWimL32hVzhyPQ91c4_uBLcAk4gSqDFyc9vndErcgymigMCtutHjWes2bMLbZMBS4YT0KFpFkj_GwStus7jdObLiaGA5guyYveAxlff9gnl2s8Owu0-a7NXlPPowYRF8TdCo6H8GDGg7UlvWMG9IOXuvNIpb_ErAFDN75oaWd0pOQI0rBZ_Fr7L5UemYD8yRQynqpnrhsoneSA0K_yUUC6pK_u1C13BKUSX7A',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      // ── Body Content ─────────────────────────────────────────────────────────
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        children: [
          // Welcome Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${_fullName ?? 'Admin'}!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'System status is healthy. ',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/admin/teacher-requests'),
                    child: const Text(
                      '2 pending faculty requests. →',
                      style: TextStyle(
                        color: AppTheme.warning,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Bento Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard(
                icon: Icons.groups_rounded,
                badge: 'Live',
                badgeColor: Colors.green,
                badgeBg: const Color(0xFFF0FDF4),
                title: 'Total Students',
                value: '$_totalStudents',
              ),
              _buildStatCard(
                icon: Icons.school_rounded,
                badge: 'Live',
                badgeColor: AppTheme.primary,
                badgeBg: const Color(0xFFFFEFEA),
                title: 'Active Courses',
                value: '$_activeCourses',
              ),
              _buildStatCard(
                icon: Icons.person_pin_rounded,
                badge: 'Live',
                badgeColor: Colors.green,
                badgeBg: const Color(0xFFF0FDF4),
                title: 'Faculty Members',
                value: '$_facultyMembers',
              ),
              _buildStatCard(
                icon: Icons.assignment_turned_in_rounded,
                badge: 'Live',
                badgeColor: AppTheme.warning,
                badgeBg: const Color(0xFFFFECE5),
                title: 'Exams Conducted',
                value: '$_examsConducted',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondary,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildQuickActionButton(
                  icon: Icons.add_circle,
                  label: 'Create Course',
                  bgColor: AppTheme.primary.withOpacity(0.1),
                  iconColor: AppTheme.primary,
                  onTap: () => context.push('/admin/courses/create'),
                ),
                const SizedBox(width: 20),
                _buildQuickActionButton(
                  icon: Icons.person_add,
                  label: 'Assign Teacher',
                  bgColor: AppTheme.secondary.withOpacity(0.1),
                  iconColor: AppTheme.secondary,
                  onTap: () => context.push('/admin/courses'),
                ),
                const SizedBox(width: 20),
                _buildQuickActionButton(
                  icon: Icons.assignment_add,
                  label: 'Manage Exams',
                  bgColor: const Color(0xFFFFF7ED),
                  iconColor: const Color(0xFFEA580C),
                  onTap: () => context.push('/exams'),
                ),
                const SizedBox(width: 20),
                _buildQuickActionButton(
                  icon: Icons.quiz_rounded,
                  label: 'Question Bank',
                  bgColor: const Color(0xFFEFF6FF),
                  iconColor: const Color(0xFF2563EB),
                  onTap: () => context.push('/questions'),
                ),
                const SizedBox(width: 20),
                _buildQuickActionButton(
                  icon: Icons.how_to_reg_rounded,
                  label: 'Faculty Requests',
                  bgColor: const Color(0xFFFDF2F8),
                  iconColor: const Color(0xFFBE185D),
                  onTap: () => context.push('/admin/teacher-requests'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // System Activity Feed
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'System Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondary,
                ),
              ),
              TextButton(
                onPressed: () => _showFeaturePendingDialog(context, 'Xem tất cả hoạt động'),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                _buildActivityItem(
                  dotColor: AppTheme.warning,
                  richText: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: AppTheme.navy, fontSize: 14),
                      children: [
                        TextSpan(text: 'New course '),
                        TextSpan(
                          text: "'Mobile App Dev'",
                          style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' created by Academic Office'),
                      ],
                    ),
                  ),
                  time: '2h ago',
                  isLast: false,
                ),
                _buildActivityItem(
                  dotColor: AppTheme.secondary,
                  richText: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: AppTheme.navy, fontSize: 14),
                      children: [
                        TextSpan(text: 'Teacher Assignment: '),
                        TextSpan(
                          text: 'Dr. Nguyen Thi Lan',
                          style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' assigned to SWE302'),
                      ],
                    ),
                  ),
                  time: '5h ago',
                  isLast: false,
                ),
                _buildActivityItem(
                  dotColor: Colors.green,
                  richText: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: AppTheme.navy, fontSize: 14),
                      children: [
                        TextSpan(text: 'System Backup completed successfully'),
                      ],
                    ),
                  ),
                  time: '1d ago',
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
      // ── Custom Bottom Nav Bar ───────────────────────────────────────────────
      bottomNavigationBar: _buildHubBottomNav(),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String badge,
    required Color badgeColor,
    required Color badgeBg,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppTheme.primary, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.secondary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required Color dotColor,
    required Widget richText,
    required String time,
    required bool isLast,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppTheme.border.withOpacity(0.5),
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                richText,
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHubBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FF),
        border: Border(top: BorderSide(color: Color(0xFFE2BFB4), width: 0.5)),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _HubBottomNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              isActive: true,
              onTap: () {},
            ),
            _HubBottomNavItem(
              icon: Icons.quiz_rounded,
              label: 'Questions',
              isActive: false,
              onTap: () => context.go(AppRouter.questionList),
            ),
            _HubBottomNavItem(
              icon: Icons.assignment_rounded,
              label: 'Exams',
              isActive: false,
              onTap: () => context.go(AppRouter.examList),
            ),
            _HubBottomNavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              isActive: false,
              onTap: () => context.go(AppRouter.profile),
            ),
          ],
        ),
      ),
    );
  }

}

class _HubBottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _HubBottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFFF15A22) : const Color(0xFF485F84);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Container(
              width: 48,
              height: 3,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF15A22),
                borderRadius: BorderRadius.circular(2),
              ),
            )
          else
            const SizedBox(height: 7),
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
