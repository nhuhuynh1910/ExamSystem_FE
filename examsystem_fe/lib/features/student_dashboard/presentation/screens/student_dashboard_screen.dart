import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/student_dashboard_bloc.dart';
import '../../bloc/student_dashboard_event.dart';
import '../../bloc/student_dashboard_state.dart';
import '../widgets/available_subjects_section.dart';
import '../widgets/my_subjects_section.dart';
import '../widgets/student_header.dart';
import '../widgets/student_stats_strip.dart';
import '../widgets/upcoming_exams_section.dart';

import '../../../../features/exam/widgets/student_exam_body.dart';
import '../../../../features/results/screens/student_results_body.dart';
import '../../../common/skeleton_loader.dart';
import '../../../profile/presentation/profile_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// StudentDashboardScreen — Màn hình shell chính cho Student.
//
// Kiến trúc: Shared Shell Pattern
//   - Scaffold DUY NHẤT bọc toàn bộ Student area
//   - Header cam (StudentHeader) hiển thị cho tab 0, 1, 2
//   - Profile (tab 3) có header riêng nên không cần SharedHeader
//   - IndexedStack chứa 4 body: Home | Exams | Results | Profile
//   - BottomNavigationBar dùng chung
//
// Index chuẩn:
//   0 → Home (Dashboard)
//   1 → Exams
//   2 → Results
//   3 → Profile
// ════════════════════════════════════════════════════════════════════════════
class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    final mainContent = Column(
      children: [
        // ── Shared Header (hiển thị cho tab 0, 1, 2 — Profile tự có header riêng)
        if (_currentIndex != 3)
          BlocBuilder<StudentDashboardBloc, StudentDashboardState>(
            builder: (context, state) {
              final String studentName = (state is StudentDashboardLoaded)
                  ? state.studentName
                  : 'Student';
              final int notifCount = (state is StudentDashboardLoaded)
                  ? state.unreadNotifications
                  : 0;
              return StudentHeader(
                studentName: studentName,
                notificationCount: notifCount,
              );
            },
          ),

        // ── Body — thay đổi theo tab, Header và BottomNav được share
        Expanded(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              // 0: Home Dashboard
              _buildHomeBody(context),
              // 1: Exams — dùng StudentExamBody (không có Scaffold)
              const StudentExamBody(),
              // 2: Results — dùng StudentResultsBody (không có Scaffold)
              const StudentResultsBody(),
              // 3: Profile — ProfileScreen có header gradient riêng
              const ProfileScreen(hideBottomNav: true),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: isDesktop
          ? Row(
              children: [
                // Desktop Adaptive NavigationRail Sidebar
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Colors.white,
                  selectedIconTheme: const IconThemeData(color: Color(0xFFF15A22)),
                  selectedLabelTextStyle: const TextStyle(
                    color: Color(0xFFF15A22),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  unselectedIconTheme: IconThemeData(color: Colors.grey.shade400),
                  unselectedLabelTextStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF3EE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Color(0xFFF15A22),
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'ExamHub',
                          style: TextStyle(
                            color: Color(0xFF1D3557),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.assignment_outlined),
                      selectedIcon: Icon(Icons.assignment_rounded),
                      label: Text('Exams'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.leaderboard_outlined),
                      selectedIcon: Icon(Icons.leaderboard_rounded),
                      label: Text('Results'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person_rounded),
                      label: Text('Profile'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: Color(0xFFE2E8F0)),
                Expanded(child: mainContent),
              ],
            )
          : mainContent,
      bottomNavigationBar: isDesktop ? null : _buildBottomNav(context),
    );
  }

  // ── Home Body ──────────────────────────────────────────────────────────────
  Widget _buildHomeBody(BuildContext context) {
    return BlocBuilder<StudentDashboardBloc, StudentDashboardState>(
      builder: (context, state) {
        if (state is StudentDashboardLoading) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SkeletonLoader(width: double.infinity, height: 90, borderRadius: 16),
                  SizedBox(height: 16),
                  SkeletonLoader(width: double.infinity, height: 48, borderRadius: 14),
                  SizedBox(height: 24),
                  SkeletonListLoader(count: 3, cardHeight: 110),
                ],
              ),
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
        return const Padding(
          padding: EdgeInsets.all(16),
          child: SkeletonListLoader(count: 3, cardHeight: 110),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, StudentDashboardLoaded state) {
    return RefreshIndicator(
      color: const Color(0xFFF15A22),
      onRefresh: () async {
        context.read<StudentDashboardBloc>().add(
              const StudentDashboardLoadRequested(),
            );
        await context.read<StudentDashboardBloc>().stream.firstWhere(
              (s) => s is StudentDashboardLoaded || s is StudentDashboardError,
            );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
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
            const SizedBox(height: 16),

            // ── Shared Global Search Bar ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1D3557)),
                  decoration: InputDecoration(
                    hintText: 'Search subjects or teachers...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFFF15A22),
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.grey.shade400,
                              size: 18,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Upcoming Exams
            UpcomingExamsSection(exams: state.upcomingExams),
            const SizedBox(height: 24),

            // Available Subjects to Enroll (Danh sách môn học mở để đăng ký)
            AvailableSubjectsSection(
              availableSubjects: state.availableCatalogSubjectsList,
              enrolledSubjects: state.subjects,
              searchQuery: _searchQuery,
            ),
            const SizedBox(height: 24),

            // My Subjects
            MySubjectsSection(
              subjects: state.subjects,
              searchQuery: _searchQuery,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
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

  // ── Bottom Navigation Bar ──────────────────────────────────────────────────
  //
  // Index chuẩn:
  //   0 → Home     (Dashboard)
  //   1 → Exams    (ExamListScreen for student)
  //   2 → Results  (ResultListScreen)
  //   3 → Profile  (ProfileScreen)
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
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
              icon: Icons.home_rounded,
              label: 'Home',
              isActive: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _BottomNavItem(
              icon: Icons.assignment_rounded,
              label: 'Exams',
              isActive: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            _BottomNavItem(
              icon: Icons.leaderboard_rounded,
              label: 'Results',
              isActive: _currentIndex == 2,
              onTap: () => setState(() => _currentIndex = 2),
            ),
            _BottomNavItem(
              icon: Icons.person_rounded,
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
          // Active indicator line ở trên cùng
          if (isActive)
            Positioned(
              top: 0,
              child: Container(
                width: 40,
                height: 3,
                decoration: const BoxDecoration(
                  color: Color(0xFFF15A22),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(2),
                    bottomRight: Radius.circular(2),
                  ),
                ),
              ),
            ),
          // Icon + Label
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
