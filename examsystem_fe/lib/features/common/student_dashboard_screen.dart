import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/storage_manager.dart';
import '../../core/network/dio_client.dart';
import '../Enrollment/models/enrollment_model.dart';
import 'student_bottom_nav_bar.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  String _fullName = 'Sinh viên';
  int _enrolledCount = 0;
  List<EnrollmentModel> _mySubjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final name = await StorageManager.getFullName();
      final studentId = await StorageManager.getUserId();
      
      if (mounted) {
        setState(() {
          _fullName = name ?? 'Sinh viên';
        });
      }

      if (studentId != null) {
        final dio = DioClient.instance;
        final response = await dio.get('/students/$studentId/subjects');
        if (response.data is List) {
          final list = (response.data as List)
              .map((item) => EnrollmentModel.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
          
          if (mounted) {
            setState(() {
              _mySubjects = list;
              _enrolledCount = list.length;
              _isLoading = false;
            });
          }
          return;
        }
      }
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      // ── Fixed Top Header ──────────────────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF15A22), // FPT Orange
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Side: FPT Logo & app name
                  Row(
                    children: [
                      Image.network(
                        'https://lh3.googleusercontent.com/aida/AP1WRLug50ElWkTK25bTdkbFNTs0ueL8sdUdFTAdYn6BEdRKSOlDEi7YEcdQj4sTsLmaD5IK-weEr5ypScfHmkmE3IQNWG9FtdrIS-QWsDrVa3MmOOL-ujtiuvtYvHxtf-175Wu36i5qDbcOM6vhjHFDVqA0LTwUsuw4rZOBcYJiZkZrEoYxdWjJpE7wxdCD74cMvcou8bdZH5YKAWkg97GyWqQ9cjIC7DCHBXbdqB6mzEb6tXpCxsKV1Rmvk1Y',
                        width: 28,
                        height: 28,
                        color: Colors.white,
                        errorBuilder: (_, __, ___) => const Icon(Icons.school, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'FPT ExamHub',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  
                  // Middle: Hello, Minh
                  Text(
                    'Hello, $_fullName 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  // Right Side: Notification Icon with Badge
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26),
                        onPressed: () {},
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFF15A22), width: 1.5),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: const Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ── Main Body ────────────────────────────────────────────────────────────
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const SizedBox(height: 8),

                  // ── Stats Horizontal List (Scrollable) ─────────────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildStatCard('Enrolled', '$_enrolledCount', Icons.book),
                        const SizedBox(width: 12),
                        _buildStatCard('Exams Taken', '12', Icons.check_circle),
                        const SizedBox(width: 12),
                        _buildStatCard('Best Score', '95%', Icons.emoji_events),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Upcoming Exams Section ─────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '📅 Upcoming Exams',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.navy,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/student/courses/catalog'),
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            color: Color(0xFFF15A22),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildUpcomingExamCard(
                          title: 'Advanced Algorithms Midterm',
                          code: 'PRN211',
                          timeLeft: 'Starts in 2 days',
                          duration: '60 min',
                        ),
                        const SizedBox(width: 12),
                        _buildUpcomingExamCard(
                          title: 'Human Computer Interaction',
                          code: 'HCI201',
                          timeLeft: 'Starts in 5 days',
                          duration: '45 min',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── My Subjects Section ────────────────────────────────────────
                  const Text(
                    '📖 My Subjects',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _mySubjects.isEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          alignment: Alignment.center,
                          child: const Text(
                            'Bạn chưa đăng ký môn học nào.',
                            style: TextStyle(color: AppTheme.textMuted),
                          ),
                        )
                      : Column(
                          children: _mySubjects.map((course) => _buildSubjectTile(course)).toList(),
                        ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

      // ── Bottom Navigation Bar ────────────────────────────────────────────────
      bottomNavigationBar: const StudentBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF15A22).withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3EE), // light orange
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFF15A22), size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingExamCard({
    required String title,
    required String code,
    required String timeLeft,
    required String duration,
  }) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border(
          left: BorderSide(color: Color(0xFFF15A22), width: 4),
          top: BorderSide(color: Color(0xFFEEEEEE)),
          right: BorderSide(color: Color(0xFFEEEEEE)),
          bottom: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.navy,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF15A22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              code,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3EE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, color: Color(0xFFF15A22), size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    timeLeft,
                    style: const TextStyle(
                      color: Color(0xFFF15A22),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.grey, size: 15),
              const SizedBox(width: 4),
              Text(
                duration,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTile(EnrollmentModel course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: Color(0xFFF15A22), width: 4),
          top: BorderSide(color: Color(0xFFEEEEEE)),
          right: BorderSide(color: Color(0xFFEEEEEE)),
          bottom: BorderSide(color: Color(0xFFEEEEEE)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.courseNameOnly,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'GV: BE Teacher',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}
