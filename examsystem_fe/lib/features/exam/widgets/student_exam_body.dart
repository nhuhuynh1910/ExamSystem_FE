import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/utils/token_storage.dart';
import '../bloc/exam_bloc.dart';
import '../bloc/exam_event.dart';
import '../bloc/exam_state.dart';
import '../models/exam_model.dart';
import '../widgets/status_chip.dart';

// ════════════════════════════════════════════════════════════════════════════
// StudentExamBody — Hiển thị danh sách bài thi dành cho Student.
//
// Widget này KHÔNG có Scaffold, AppBar hay BottomNavigationBar.
// Được nhúng vào IndexedStack trong StudentDashboardScreen (index = 1).
//
// Layout: TabBar (All / Available / Upcoming / Closed) + Filter + ExamList
// ════════════════════════════════════════════════════════════════════════════
class StudentExamBody extends StatefulWidget {
  const StudentExamBody({super.key});

  @override
  State<StudentExamBody> createState() => _StudentExamBodyState();
}

class _StudentExamBodyState extends State<StudentExamBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _statuses = ['All', 'Available', 'Upcoming', 'Closed'];
  bool _isSearchVisible = false;
  int? _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _initScreen();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initScreen() async {
    final userId = await TokenStorage.getUserId() ?? 0;
    if (mounted) {
      // Load môn học của Student (để lọc exam theo môn đã đăng ký)
      context.read<ExamBloc>().add(LoadStudentSubjectsEvent(userId));
      _loadExams();
    }
  }

  void _loadExams() {
    context.read<ExamBloc>().add(const LoadExamsEvent());
  }

  void _onExamTap(ExamModel exam) {
    context.push(AppRouter.waitingRoom, extra: exam);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Tab Bar ─────────────────────────────────────────────────────────
        Container(
          color: const Color(0xFFF97316),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: _statuses.map((s) => Tab(text: s)).toList(),
          ),
        ),

        // ── Search + Filter Bar ──────────────────────────────────────────────
        _buildFilterBar(),

        // ── Exam List ────────────────────────────────────────────────────────
        Expanded(
          child: BlocBuilder<ExamBloc, ExamState>(
            builder: (context, state) {
              if (state.isLoading && state.exams.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFF97316)),
                );
              }

              var exams = state.exams;

              // Lọc theo môn học đã đăng ký
              if (state.subjects.isNotEmpty) {
                final allowedIds = state.subjects.map((s) => s.subjectId).toSet();
                exams = exams.where((e) => allowedIds.contains(e.subjectId)).toList();
              }

              // Lọc theo tab
              exams = _filterByTab(exams);

              // Lọc theo tìm kiếm
              if (_searchController.text.isNotEmpty) {
                final q = _searchController.text.toLowerCase();
                exams = exams.where((e) => e.examName.toLowerCase().contains(q)).toList();
              }

              // Lọc theo môn được chọn trong dropdown
              if (_selectedSubjectId != null) {
                exams = exams.where((e) => e.subjectId == _selectedSubjectId).toList();
              }

              if (exams.isEmpty) return _buildEmptyState();

              return RefreshIndicator(
                onRefresh: () async => _loadExams(),
                color: const Color(0xFFF97316),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: exams.length,
                  itemBuilder: (context, index) => _buildExamCard(exams[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Filter Bar ─────────────────────────────────────────────────────────────
  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              // Subject dropdown
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: BlocBuilder<ExamBloc, ExamState>(
                      builder: (context, state) => DropdownButton<int>(
                        value: _selectedSubjectId,
                        isExpanded: true,
                        hint: const Text(
                          'All Subjects',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('All Subjects', style: TextStyle(fontSize: 13)),
                          ),
                          ...state.subjects.map(
                            (s) => DropdownMenuItem(
                              value: s.subjectId,
                              child: Text(s.subjectName, style: const TextStyle(fontSize: 13)),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() {
                          _selectedSubjectId = v;
                        }),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Search toggle button
              GestureDetector(
                onTap: () => setState(() {
                  _isSearchVisible = !_isSearchVisible;
                  if (!_isSearchVisible) _searchController.clear();
                }),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: _isSearchVisible
                        ? const Color(0xFFF97316).withValues(alpha: 0.1)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isSearchVisible
                          ? const Color(0xFFF97316)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Icon(
                    _isSearchVisible ? Icons.close : Icons.search,
                    size: 20,
                    color: _isSearchVisible ? const Color(0xFFF97316) : Colors.grey,
                  ),
                ),
              ),
            ],
          ),

          // Search field (hidden by default)
          if (_isSearchVisible)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFF97316).withValues(alpha: 0.5),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Tìm kiếm bài thi...',
                    prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFFF97316)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Tab Filter Logic ──────────────────────────────────────────────────────
  List<ExamModel> _filterByTab(List<ExamModel> exams) {
    final now = DateTime.now();
    switch (_tabController.index) {
      case 1: // Available — đang mở, trong thời gian thi
        return exams
            .where((e) =>
                e.status == 'Published' &&
                e.startTime != null &&
                e.endTime != null &&
                now.isAfter(e.startTime!) &&
                now.isBefore(e.endTime!))
            .toList();
      case 2: // Upcoming — chưa đến giờ
        return exams
            .where((e) =>
                e.status == 'Published' &&
                e.startTime != null &&
                now.isBefore(e.startTime!))
            .toList();
      case 3: // Closed — đã kết thúc
        return exams
            .where((e) =>
                e.status == 'Closed' ||
                (e.endTime != null && now.isAfter(e.endTime!)))
            .toList();
      default: // All — tất cả Published + Closed
        return exams
            .where((e) => e.status == 'Published' || e.status == 'Closed')
            .toList();
    }
  }

  // ── Exam Card ──────────────────────────────────────────────────────────────
  Widget _buildExamCard(ExamModel exam) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _onExamTap(exam),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar chữ cái đầu
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFF97316).withValues(alpha: 0.1),
                child: Text(
                  exam.examName.isNotEmpty
                      ? exam.examName[0].toUpperCase()
                      : 'E',
                  style: const TextStyle(
                    color: Color(0xFFF97316),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.examName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (exam.subjectName ?? 'Subject').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFF97316),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${exam.durationMinutes} mins',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.calendar_today, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy')
                              .format(exam.startTime ?? DateTime.now()),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status chip + chevron
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(status: exam.status),
                  const SizedBox(height: 6),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Không có bài thi nào',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Các bài thi của bạn sẽ xuất hiện ở đây',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
