import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/storage_manager.dart';
import '../../../core/utils/token_storage.dart';
import '../../exam/models/subject_model.dart';
import '../bloc/question_bloc.dart';
import '../bloc/question_event.dart';
import '../bloc/question_state.dart';
import 'create_question_screen.dart';

class QuestionListScreen extends StatefulWidget {
  const QuestionListScreen({super.key});

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  final List<int> _selectedIds = [];
  bool _isSearchOpen = false;
  final _searchController = TextEditingController();
  String? _userRole;
  String? _userName;

  // Filters
  int? _selectedSubjectId;
  String? _selectedDifficulty;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  Future<void> _initScreen() async {
    _userRole = await TokenStorage.getRole();
    _userName = await TokenStorage.getFullName();
    if (mounted) {
      context.read<QuestionBloc>().add(LoadSubjectsEvent());
      _loadQuestions();
      setState(() {});
    }
  }

  void _loadQuestions() {
    final params = <String, dynamic>{};
    if (_searchController.text.isNotEmpty) params['search'] = _searchController.text;
    
    // Nếu là Teacher, bắt buộc phải lọc theo môn học được giao
    if (_userRole == 'Teacher') {
      if (_selectedSubjectId != null) {
        params['subjectId'] = _selectedSubjectId;
      }
      // Lưu ý: Backend Question API cần đảm bảo chỉ trả về câu hỏi 
      // của các môn mà Teacher này phụ trách nếu không có subjectId cụ thể.
    } else {
      if (_selectedSubjectId != null) params['subjectId'] = _selectedSubjectId;
    }

    if (_selectedDifficulty != null) params['difficulty'] = _selectedDifficulty;
    if (_selectedStatus != null) params['status'] = _selectedStatus;

    context.read<QuestionBloc>().add(LoadQuestionsEvent(queryParameters: params));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0xFFF97316)),
        title: _isSearchOpen
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Search questions...', border: InputBorder.none),
                onChanged: (v) => _loadQuestions(),
              )
            : const Text('Question Bank', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isSearchOpen ? Icons.close : Icons.search, color: const Color(0xFFF97316)),
            onPressed: () => setState(() {
              _isSearchOpen = !_isSearchOpen;
              if (!_isSearchOpen) _searchController.clear();
            }),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Color(0xFFF97316)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<QuestionBloc, QuestionState>(
        listener: (context, state) {
          if (state is QuestionOperationSuccess && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
            );
          }
        },
        builder: (context, state) {
          final questions = state.questions ?? [];

          if (state.isLoading && questions.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)));
          }

          return Column(
            children: [
              _buildFilters(state.subjects ?? []),
              Expanded(
                child: Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () async => _loadQuestions(),
                      color: const Color(0xFFF97316),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final question = questions[index];
                          final isSelected = _selectedIds.contains(question.questionId);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFFF97316) : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                if (_selectedIds.isNotEmpty) {
                                  setState(() {
                                    isSelected ? _selectedIds.remove(question.questionId) : _selectedIds.add(question.questionId);
                                  });
                                }
                              },
                              onLongPress: () => setState(() => _selectedIds.add(question.questionId)),
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        if (_selectedIds.isNotEmpty)
                                          Checkbox(
                                            value: isSelected,
                                            activeColor: const Color(0xFFF97316),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                            onChanged: (v) => setState(() => v! ? _selectedIds.add(question.questionId) : _selectedIds.remove(question.questionId)),
                                          ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: const Color(0xFFF97316).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                          child: Text(question.subjectName.toUpperCase(), style: const TextStyle(color: Color(0xFFF97316), fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                        const Spacer(),
                                        _buildStatusBadge(question.status),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      question.content,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, height: 1.4),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        _buildInfoBadge(question.difficulty, _getDiffColor(question.difficulty)),
                                        const SizedBox(width: 8),
                                        _buildInfoBadge('${question.score} pts', Colors.blueGrey),
                                        const Spacer(),
                                        if (question.status == 'Draft')
                                          TextButton(
                                            onPressed: () => context.read<QuestionBloc>().add(PublishQuestionEvent(question.questionId)),
                                            child: const Text('Publish', style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold)),
                                          )
                                        else
                                          TextButton(
                                            onPressed: () => context.read<QuestionBloc>().add(DraftQuestionEvent(question.questionId)),
                                            child: Text('Set to Draft', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_selectedIds.isNotEmpty) _buildBottomActions(questions),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _selectedIds.isEmpty
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFF97316),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateQuestionScreen())).then((_) => _loadQuestions()),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildFilters(List<SubjectModel> subjects) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Subject Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedSubjectId,
                hint: const Text('Subject', style: TextStyle(fontSize: 12)),
                style: const TextStyle(fontSize: 12, color: Colors.black),
                items: [
                  const DropdownMenuItem<int>(value: null, child: Text('All Subjects')),
                  ...subjects.map((s) => DropdownMenuItem(value: s.subjectId, child: Text(s.subjectName))),
                ],
                onChanged: (v) => setState(() { _selectedSubjectId = v; _loadQuestions(); }),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Difficulty Filter
          _buildDropdownFilter('Difficulty', _selectedDifficulty, ['Easy', 'Medium', 'Hard'], (v) {
            setState(() { _selectedDifficulty = v; _loadQuestions(); });
          }),
          const SizedBox(width: 8),
          // Status Filter
          _buildDropdownFilter('Status', _selectedStatus, ['Draft', 'Published'], (v) {
            setState(() { _selectedStatus = v; _loadQuestions(); });
          }),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(String hint, String? value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 12)),
          style: const TextStyle(fontSize: 12, color: Colors.black),
          items: [
            DropdownMenuItem<String>(value: null, child: Text('All $hint')),
            ...items.map((i) => DropdownMenuItem(value: i, child: Text(i))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildBottomActions(List questions) {
    final allDraft = _selectedIds.every((id) => questions.firstWhere((q) => q.questionId == id).status == 'Draft');
    final allPublished = _selectedIds.every((id) => questions.firstWhere((q) => q.questionId == id).status == 'Published');

    return Positioned(
      bottom: 24, left: 20, right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15)],
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Text('${_selectedIds.length} items', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (!allPublished)
              TextButton(
                onPressed: () => _confirmBulkAction('Publish selected questions?', () {
                  for (var id in _selectedIds) {
                    context.read<QuestionBloc>().add(PublishQuestionEvent(id));
                  }
                }),
                child: const Text('PUBLISH', style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold)),
              ),
            if (!allDraft)
              TextButton(
                onPressed: () => _confirmBulkAction('Move selected questions to Draft?', () {
                  for (var id in _selectedIds) {
                    context.read<QuestionBloc>().add(DraftQuestionEvent(id));
                  }
                }),
                child: const Text('DRAFT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setState(() => _selectedIds.clear())),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isPublished = status.toLowerCase() == 'published';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: isPublished ? Colors.green[50] : Colors.grey[100], borderRadius: BorderRadius.circular(6)),
      child: Text(status.toUpperCase(), style: TextStyle(color: isPublished ? Colors.green[700] : Colors.grey[600], fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Color _getDiffColor(String d) {
    switch (d.toLowerCase()) {
      case 'easy': return Colors.green;
      case 'medium': return Colors.orange;
      case 'hard': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _confirmBulkAction(String title, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              onConfirm();
              setState(() => _selectedIds.clear());
              Navigator.pop(ctx);
            },
            child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF97316))),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    final bool isTeacher = _userRole == 'Teacher';
    final bool isAdmin = _userRole == 'Admin';

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFF97316)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                isAdmin ? Icons.admin_panel_settings : (isTeacher ? Icons.school : Icons.person),
                size: 40,
                color: const Color(0xFFF97316),
              ),
            ),
            accountName: Text(_userName ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(_userRole ?? 'Role'),
          ),
          ListTile(
            leading: const Icon(Icons.assignment_outlined, color: Color(0xFFF97316)),
            title: const Text('Exams'),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRouter.examList);
            },
          ),
          ListTile(
            leading: const Icon(Icons.quiz_outlined, color: Color(0xFFF97316)),
            title: const Text('Question Bank'),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout'),
            onTap: () async {
              await StorageManager.clearAll();
              if (mounted) context.go(AppRouter.login);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
