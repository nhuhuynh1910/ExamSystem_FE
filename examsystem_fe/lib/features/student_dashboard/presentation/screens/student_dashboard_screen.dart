import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/student_dashboard_bloc.dart';
import '../../bloc/student_dashboard_event.dart';
import '../../bloc/student_dashboard_state.dart';
import '../widgets/my_subjects_section.dart';
import '../widgets/student_header.dart';
import '../widgets/student_stats_strip.dart';
import '../widgets/upcoming_exams_section.dart';

import '../../../profile/presentation/profile_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// StudentDashboardScreen — Màn hình chính cho Student.
//
// Gồm:
//   - Header cam cố định (logo + tên SV + notification)
//   - Stats Strip (Enrolled, Exams Taken, Best Score)
//   - Upcoming Exams (horizontal scroll cards)
//   - My Subjects (vertical list cards)
//   - Bottom Navigation Bar (Home ↔ Profile tích hợp liền mạch)
// ════════════════════════════════════════════════════════════════════════════
class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // 0: Home Dashboard
          _buildHomeBody(context),
          // 1: Exams (placeholder)
          _buildPlaceholder('Exams', Icons.assignment),
          // 2: Results (placeholder)
          _buildPlaceholder('Results', Icons.leaderboard),
          // 3: Profile Screen embedded
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHomeBody(BuildContext context) {
    return BlocBuilder<StudentDashboardBloc, StudentDashboardState>(
      builder: (context, state) {
        if (state is StudentDashboardLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFF15A22),
            ),
          );
        }

        if (state is StudentDashboardError) {
          return _buildError(context, state.message);
        }

        if (state is StudentDashboardLoaded) {
          return _buildContent(context, state);
        }

        // Initial state
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFF15A22),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, StudentDashboardLoaded state) {
    return Column(
      children: [
        // Fixed header
        StudentHeader(
          studentName: state.studentName,
          notificationCount: state.unreadNotifications,
        ),

        // Scrollable body with pull-to-refresh
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFFF15A22),
            onRefresh: () async {
              context.read<StudentDashboardBloc>().add(
                    const StudentDashboardLoadRequested(),
                  );
              // Đợi state chuyển sang Loaded/Error
              await context.read<StudentDashboardBloc>().stream.firstWhere(
                    (s) =>
                        s is StudentDashboardLoaded ||
                        s is StudentDashboardError,
                  );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Stats Strip
                  StudentStatsStrip(
                    enrolledCount: state.enrolledCount,
                    examsTakenCount: state.examsTakenCount,
                    bestScore: state.bestScore,
                  ),
                  const SizedBox(height: 24),

                  // Upcoming Exams
                  UpcomingExamsSection(exams: state.upcomingExams),
                  const SizedBox(height: 24),

                  // My Subjects
                  MySubjectsSection(subjects: state.subjects),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFBA1A1A),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF485F84),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<StudentDashboardBloc>().add(
                      const StudentDashboardLoadRequested(),
                    );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF15A22),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: const Color(0xFFF15A22)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D3557),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coming soon!',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF485F84),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Navigation Bar ────────────────────────────────────────────────
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF), // surface
        border: const Border(
          top: BorderSide(color: Color(0xFFE2BFB4), width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              icon: Icons.home,
              label: 'Home',
              isActive: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _BottomNavItem(
              icon: Icons.assignment,
              label: 'Exams',
              isActive: _currentIndex == 1,
              onTap: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: const Text('Coming soon!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
              },
            ),
            _BottomNavItem(
              icon: Icons.leaderboard,
              label: 'Results',
              isActive: _currentIndex == 2,
              onTap: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: const Text('Coming soon!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
              },
            ),
            _BottomNavItem(
              icon: Icons.person,
              label: 'Profile',
              isActive: _currentIndex == 3,
              onTap: () => setState(() => _currentIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Nav Item Widget ─────────────────────────────────────────────────
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFFF15A22) : Colors.grey.shade400;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Active indicator — position: absolute; top: 0 (theo prototype CSS)
          if (isActive)
            Positioned(
              top: 0,
              child: Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFFF15A22),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(2),
                    bottomRight: Radius.circular(2),
                  ),
                ),
              ),
            ),
          // Nội dung icon + label
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
          ),
        ],
      ),
    );
  }
}
