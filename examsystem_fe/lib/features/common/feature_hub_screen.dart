import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/storage_manager.dart';
import '../../core/network/dio_client.dart';
import 'admin_bottom_nav_bar.dart';

/// FeatureHubScreen — Trang trung tâm Admin Dashboard.
class FeatureHubScreen extends StatefulWidget {
  const FeatureHubScreen({super.key});

  @override
  State<FeatureHubScreen> createState() => _FeatureHubScreenState();
}

class _FeatureHubScreenState extends State<FeatureHubScreen> {
  String? _fullName;

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
    if (mounted) {
      setState(() {
        _fullName = fullName ?? 'User';
      });
    }
  }

  void _showFeaturePendingDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(featureName),
        content: Text('Feature "$featureName" is under development and will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // ── Top App Bar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppTheme.primary),
          onPressed: () => _showFeaturePendingDialog(context, 'Menu'),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              'https://lh3.googleusercontent.com/aida/AP1WRLs9uI4gDsk_p6lAI1OqbHDXyKZBdrqeBA-bY4xnIk1CUgoqLvT_0KFZMolYwqah0XQ8B8y5zcmkzSSW6y3731qbMPyW-67cNO6_wYkU0U9d4m65t2DRuN2P389YSNot3Qgpt2xkLrQGShRsIIQ8tEfu1R2x3BYDpsAKOJ9FjtpDRLqnXyPR15zqIJJxnXq_rXCEWeN_DpYjvdpwEbesYOMwglGphQdkDOQze_e7a1ekrgEmmZGg_9Cereg',
              height: 32,
              errorBuilder: (_, __, ___) => const Icon(Icons.school_rounded, color: AppTheme.primary),
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
            icon: const Icon(Icons.notifications_outlined, color: AppTheme.secondary),
            onPressed: () => context.push('/notifications'),
            tooltip: 'Notifications',
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        children: [
          // Welcome Header Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E293B).withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF10B981), width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
                          SizedBox(width: 6),
                          Text(
                            'System Active',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.shield_outlined, color: Colors.white70, size: 22),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Welcome back, ${_fullName ?? 'Admin'}!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Academic Office Administration Hub',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Overview Title
          const Text(
            'System Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondary,
            ),
          ),
          const SizedBox(height: 14),

          // Stats Bento Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                icon: Icons.groups_rounded,
                badge: 'Live',
                color: const Color(0xFF2563EB),
                title: 'Total Students',
                value: '$_totalStudents',
              ),
              _buildStatCard(
                icon: Icons.school_rounded,
                badge: 'Live',
                color: AppTheme.primary,
                title: 'Active Courses',
                value: '$_activeCourses',
              ),
              _buildStatCard(
                icon: Icons.person_pin_rounded,
                badge: 'Live',
                color: const Color(0xFF7C3AED),
                title: 'Faculty Members',
                value: '$_facultyMembers',
              ),
              _buildStatCard(
                icon: Icons.assignment_turned_in_rounded,
                badge: 'Live',
                color: const Color(0xFF059669),
                title: 'Exams Conducted',
                value: '$_examsConducted',
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondary,
            ),
          ),
          const SizedBox(height: 14),

          // Balanced 3-Column Quick Actions Layout
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Create Course',
                  bgColor: AppTheme.primary.withOpacity(0.08),
                  iconColor: AppTheme.primary,
                  onTap: () => context.push('/admin/courses/create'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.person_add_alt_1_rounded,
                  label: 'Assign Teacher',
                  bgColor: const Color(0xFF7C3AED).withOpacity(0.08),
                  iconColor: const Color(0xFF7C3AED),
                  onTap: () => context.push('/admin/courses'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.how_to_reg_rounded,
                  label: 'Faculty Requests',
                  bgColor: const Color(0xFF059669).withOpacity(0.08),
                  iconColor: const Color(0xFF059669),
                  onTap: () => context.push('/admin/teacher-requests'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
      // ── Admin Bottom Nav Bar ───────────────────────────────────────────────
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String badge,
    required Color color,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 12,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      badge,
                      style: const TextStyle(
                        color: Color(0xFF047857),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: AppTheme.secondary,
                  fontSize: 22,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border.withOpacity(0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.navy,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
