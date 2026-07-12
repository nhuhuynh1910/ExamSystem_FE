import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/token_storage.dart';
import '../../question/bloc/question_bloc.dart';
import '../../question/bloc/question_event.dart' as qe;
import '../../question/bloc/question_state.dart';
import '../bloc/exam_bloc.dart';
import '../bloc/exam_event.dart';
import '../bloc/exam_state.dart';
import '../models/exam_model.dart';
import '../models/subject_model.dart';
import '../widgets/exam_card.dart';
import '../widgets/status_chip.dart';
import 'create_exam_screen.dart';
import 'exam_detail_screen.dart';
import 'update_exam_screen.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> _statuses = ['All', 'Draft', 'Published', 'Closed'];
  String? _userRole;
  String? _userName;

  // Filters
  final TextEditingController _searchController = TextEditingController();
  int? _selectedSubjectId;
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _initScreen();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initScreen() async {
    await _loadUserInfo();
    if (_userRole == 'Admin') {
      setState(() {
        _statuses = ['All', 'Draft', 'Published', 'Closed', 'Deleted'];
        _tabController = TabController(length: _statuses.length, vsync: this);
        _tabController.addListener(_onTabChanged);
      });
    }
    _loadExams();
    if (mounted) {
      context.read<ExamBloc>().add(const LoadSubjectsEvent());
      _loadQuestionCount();
    }
  }

  Future<void> _loadUserInfo() async {
    final role = await TokenStorage.getRole();
    if (mounted) {
      setState(() {
        _userRole = role;
        _userName = role == 'Admin' ? 'Admin' : (role == 'Teacher' ? 'Teacher' : 'Student');
      });
    }
  }

  void _loadQuestionCount() {
    context.read<QuestionBloc>().add(qe.LoadQuestionsEvent(
          queryParameters: _selectedSubjectId != null ? {'SubjectId': _selectedSubjectId} : null,
        ));
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _loadExams();
    }
  }

  void _loadExams() {
    final status = _statuses[_tabController.index];
    if (_userRole == 'Admin') {
      context.read<ExamBloc>().add(LoadExamsEvent(
            subjectId: _selectedSubjectId,
          ));
    } else if (_userRole == 'Teacher') {
      context.read<ExamBloc>().add(
            LoadTeacherExamsEvent(
              status: status == 'All' ? null : status,
              subjectId: _selectedSubjectId,
            ),
          );
    } else {
      // Student view: Load all exams and filter in UI based on enrolled subjects
      context.read<ExamBloc>().add(const LoadExamsEvent());
    }
  }

  void _onExamTap(ExamModel exam) {
    if (_userRole == 'Student') {
      context.push(AppRouter.waitingRoom, extra: exam);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ExamDetailScreen(examId: exam.examId)),
      ).then((_) => _loadExams());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userRole == 'Student') return _buildStudentView();
    return _buildTeacherAdminView();
  }

  // ─── TEACHER/ADMIN VIEW ──────────────────────────────────────────────────────
  Widget _buildTeacherAdminView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocListener<ExamBloc, ExamState>(
        listener: (context, state) {
          if (state is ExamOperationSuccess) {
            _loadExams();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message!),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
          }
          if (state is ExamError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
          }
        },
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(child: _buildTeacherHeader()),
            SliverAppBar(
              pinned: true,
              floating: true,
              elevation: 0,
              toolbarHeight: 0,
              backgroundColor: const Color(0xFFF8FAFC),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(_isSearchVisible ? 180 : 130),
                child: Column(
                  children: [
                    _buildTeacherTabBar(),
                    _buildFilterSection(),
                  ],
                ),
              ),
            ),
          ],
          body: BlocBuilder<ExamBloc, ExamState>(
            builder: (context, state) {
              var exams = state.exams ?? [];

              if (_userRole == 'Admin' && _statuses[_tabController.index] != 'All') {
                exams = exams.where((e) => e.status == _statuses[_tabController.index]).toList();
              }
              if (_selectedSubjectId != null) {
                exams = exams.where((e) => e.subjectId == _selectedSubjectId).toList();
              }
              if (_searchController.text.isNotEmpty) {
                final query = _searchController.text.toLowerCase();
                exams = exams.where((e) => e.examName.toLowerCase().contains(query)).toList();
              }

              if (state.isLoading && exams.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)));
              }

              return RefreshIndicator(
                onRefresh: () async => _loadExams(),
                color: const Color(0xFFF97316),
                child: exams.isEmpty ? _buildEmptyState() : _buildExamList(exams),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFF97316),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateExamScreen())).then((_) => _loadExams()),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Exam', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildTeacherHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF97316),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, ${_userName ?? 'User'}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Text('Manage your exams efficiently', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 24),
          BlocBuilder<ExamBloc, ExamState>(
            builder: (context, examState) => BlocBuilder<QuestionBloc, QuestionState>(
              builder: (context, qState) => Row(
                children: [
                  _buildStatCard((qState.questions?.length ?? 0).toString(), 'Questions', Icons.help_outline),
                  const SizedBox(width: 12),
                  _buildStatCard((examState.exams?.length ?? 0).toString(), 'Exams', Icons.assignment_outlined),
                  const SizedBox(width: 12),
                  _buildStatCard(examState.exams?.where((e) => e.status == 'Published').length.toString() ?? '0', 'Active', Icons.bolt),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _quickAction(Icons.add_box_outlined, 'New Question', () => context.push(AppRouter.questionBank)),
        const SizedBox(width: 48),
        _quickAction(Icons.note_add_outlined, 'New Exam', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateExamScreen()))),
      ],
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: const Color(0xFFF97316)),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: const Color(0xFFF97316)),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      height: 40,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(20)),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelPadding: const EdgeInsets.symmetric(horizontal: 20),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: _statuses.map((s) => Tab(text: s)).toList(),
      ),
    );
  }

  // ─── STUDENT VIEW ──────────────────────────────────────────────────────────
  Widget _buildStudentView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
        elevation: 0,
        title: _isSearchVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'Search exams...', hintStyle: TextStyle(color: Colors.white70), border: InputBorder.none),
                onChanged: (v) => setState(() {}),
              )
            : const Text('Exams', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () => setState(() {
              _isSearchVisible = !_isSearchVisible;
              if (!_isSearchVisible) _searchController.clear();
            }),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildStudentTabs(),
          Expanded(
            child: BlocBuilder<ExamBloc, ExamState>(
              builder: (context, state) {
                if (state.isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)));

                var exams = state.exams ?? [];
                final enrolledIds = (state.subjects ?? []).map((s) => s.subjectId).toSet();

                // 1. Filter by enrolled subjects
                exams = exams.where((e) => enrolledIds.contains(e.subjectId)).toList();

                // 2. Search filter
                if (_searchController.text.isNotEmpty) {
                  exams = exams.where((e) => e.examName.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
                }

                // 3. Tab status filter
                exams = _filterByStudentTab(exams);

                if (exams.isEmpty) return _buildEmptyState();

                return RefreshIndicator(
                  onRefresh: () async => _loadExams(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: exams.length,
                    itemBuilder: (context, index) => _buildStudentExamCard(exams[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTabs() {
    return Container(
      color: const Color(0xFFF97316),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: _statuses.map((s) => Tab(text: s)).toList(),
      ),
    );
  }

  List<ExamModel> _filterByStudentTab(List<ExamModel> exams) {
    final now = DateTime.now();
    switch (_tabController.index) {
      case 1: // Available
        return exams.where((e) => e.status == 'Published' && now.isAfter(e.startTime) && now.isBefore(e.endTime)).toList();
      case 2: // Upcoming
        return exams.where((e) => e.status == 'Published' && now.isBefore(e.startTime)).toList();
      case 3: // Closed
        return exams.where((e) => e.status == 'Closed' || now.isAfter(e.endTime)).toList();
      default: // All Published
        return exams.where((e) => e.status == 'Published' || e.status == 'Closed').toList();
    }
  }

  Widget _buildStudentExamCard(ExamModel exam) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: InkWell(
        onTap: () => _onExamTap(exam),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFF97316).withOpacity(0.1),
                child: Text(exam.examName.isNotEmpty ? exam.examName[0].toUpperCase() : 'E', style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exam.examName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                    const SizedBox(height: 4),
                    Text((exam.subjectName ?? 'Subject').toUpperCase(), style: const TextStyle(fontSize: 10, color: Color(0xFFF97316), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${exam.durationMinutes} mins', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(DateFormat('MMM dd').format(exam.startTime), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  StatusChip(status: exam.status),
                  const SizedBox(height: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SHARED WIDGETS ────────────────────────────────────────────────────────
  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 42,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                  child: DropdownButtonHideUnderline(
                    child: BlocBuilder<ExamBloc, ExamState>(
                      builder: (context, state) => DropdownButton<int>(
                        value: _selectedSubjectId,
                        hint: const Text('Filter Subject', style: TextStyle(fontSize: 13)),
                        items: [const DropdownMenuItem(value: null, child: Text('All Subjects')), ...(state.subjects ?? []).map((s) => DropdownMenuItem(value: s.subjectId, child: Text(s.subjectName)))],
                        onChanged: (v) => setState(() {
                          _selectedSubjectId = v;
                          _loadExams();
                          _loadQuestionCount();
                        }),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: _isSearchVisible ? const Color(0xFFF97316).withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _isSearchVisible ? const Color(0xFFF97316) : Colors.grey[200]!),
                ),
                child: IconButton(
                    icon: Icon(_isSearchVisible ? Icons.close : Icons.search, size: 20, color: _isSearchVisible ? const Color(0xFFF97316) : Colors.grey),
                    onPressed: () => setState(() {
                          _isSearchVisible = !_isSearchVisible;
                          if (!_isSearchVisible) {
                            _searchController.clear();
                          }
                        })),
              ),
            ],
          ),
          if (_isSearchVisible)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                height: 42,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF97316).withOpacity(0.5))),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Search exam by name...',
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

  Widget _buildExamList(List exams) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        final exam = exams[index] as ExamModel;
        return ExamCard(
          exam: exam,
          onTap: () => _onExamTap(exam),
          onAction: (action) => _handleExamAction(exam, action),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No exams matching your criteria', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _handleExamAction(ExamModel exam, String action) {
    switch (action) {
      case 'edit':
        Navigator.push(context, MaterialPageRoute(builder: (_) => UpdateExamScreen(exam: exam))).then((_) => _loadExams());
        break;
      case 'publish':
        context.read<ExamBloc>().add(PublishExamEvent(exam.examId));
        break;
      case 'close':
        context.read<ExamBloc>().add(CloseExamEvent(exam.examId));
        break;
      case 'restore':
        context.read<ExamBloc>().add(RestoreExamEvent(exam.examId));
        break;
      case 'delete':
        _confirmDelete(context, exam.examId);
        break;
    }
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: const [Icon(Icons.warning_amber_rounded, color: Colors.red), SizedBox(width: 8), Text('Delete Exam?')]),
        content: const Text('Are you sure you want to delete this exam? This action can be undone by Admin.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: Colors.grey[600]))),
          TextButton(
            onPressed: () {
              context.read<ExamBloc>().add(DeleteExamEvent(id));
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
