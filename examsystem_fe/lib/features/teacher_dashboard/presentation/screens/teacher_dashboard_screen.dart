import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/teacher_dashboard_bloc.dart';
import '../../bloc/teacher_dashboard_event.dart';
import '../../bloc/teacher_dashboard_state.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/exam_card.dart';
import '../widgets/exam_filter_tabs.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/stats_strip.dart';
import '../../../../core/routes/app_router.dart';

import '../../../profile/presentation/profile_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// TeacherDashboardScreen — Màn hình chính cho Teacher.
//
// Gồm:
//   - Header cam cố định (tên GV + notification)
//   - Quick Actions (4 nút)
//   - Stats Strip (Questions, Exams, Attempts)
//   - My Exams (filter tabs + danh sách card)
//   - Recent Activity (timeline mock)
//   - Bottom Navigation Bar (Home <-> Profile tích hợp liền mạch)
// ════════════════════════════════════════════════════════════════════════════
class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
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
          // 1: Questions (placeholder / coming soon)
          _buildHomeBody(context),
          // 2: Exams (placeholder / coming soon)
          _buildHomeBody(context),
          // 3: Profile Screen embedded
          const ProfileScreen(hideBottomNav: true),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHomeBody(BuildContext context) {
    return BlocBuilder<TeacherDashboardBloc, TeacherDashboardState>(
      builder: (context, state) {
        if (state is TeacherDashboardLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFF15A22),
            ),
          );
        }

        if (state is TeacherDashboardError) {
          return _buildError(context, state.message);
        }

        if (state is TeacherDashboardLoaded) {
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

  Widget _buildContent(BuildContext context, TeacherDashboardLoaded state) {
    return Column(
      children: [
        // Fixed header
        DashboardHeader(
          teacherName: state.teacherName,
        ),

        // Scrollable body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Quick Actions
                const QuickActionsGrid(),
                const SizedBox(height: 24),

                // Stats Strip
                StatsStrip(
                  totalQuestions: state.totalQuestions,
                  totalExams: state.totalExams,
                  totalAttempts: state.totalAttempts,
                ),
                const SizedBox(height: 24),

                // My Exams Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Exams',
                        style: TextStyle(
                          color: Color(0xFF1D3557),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push(AppRouter.examList);
                        },
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            color: Color(0xFFF15A22),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Tabs
                ExamFilterTabs(
                  activeFilter: state.activeFilter,
                  onFilterChanged: (filter) {
                    context.read<TeacherDashboardBloc>().add(
                          TeacherDashboardFilterChanged(filter),
                        );
                  },
                ),
                const SizedBox(height: 12),

                // Exam Cards
                if (state.filteredExams.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 48,
                            color: Color(0xFF485F84),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No exams found',
                            style: TextStyle(
                              color: Color(0xFF485F84),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: state.filteredExams.map((exam) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ExamCard(exam: exam),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
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
                context.read<TeacherDashboardBloc>().add(
                      const TeacherDashboardLoadRequested(),
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

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FF),
        border: Border(
          top: BorderSide(color: Color(0xFFE2BFB4), width: 0.5),
        ),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home
            _BottomNavItem(
              icon: Icons.home,
              label: 'Home',
              isActive: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            // Questions
            _BottomNavItem(
              icon: Icons.quiz,
              label: 'Questions',
              isActive: _currentIndex == 1,
              onTap: () => context.go(AppRouter.questionList),
            ),
            // Exams
            _BottomNavItem(
              icon: Icons.assignment,
              label: 'Exams',
              isActive: _currentIndex == 2,
              onTap: () => context.go(AppRouter.examList),
            ),
            // Profile
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
    final color = isActive ? const Color(0xFFF15A22) : const Color(0xFF485F84);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active indicator bar
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
