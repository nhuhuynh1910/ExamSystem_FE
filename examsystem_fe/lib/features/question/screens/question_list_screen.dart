import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/storage_manager.dart';
import '../../exam/models/subject_model.dart';
import '../bloc/question_bloc.dart';
import '../bloc/question_event.dart';
import '../bloc/question_state.dart';
import '../models/question_model.dart';
import 'create_question_screen.dart';

import 'update_question_screen.dart';

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
    _userRole = await StorageManager.getRole();
    _userName = await StorageManager.getFullName();
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
      backgroundColor: const Color(0xfff6f7fb),
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
          if (state is QuestionSuccess && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final questions = state.questions ?? [];

          return Column(
            children: [
              _buildFilters(state.subjects ?? []),
              if (state.isLoading)
                const LinearProgressIndicator(
                  color: Color(0xFFF97316),
                  backgroundColor: Colors.transparent,
                  minHeight: 2,
                ),
              Expanded(
                child: state.isLoading && questions.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)))
                    : questions.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.quiz_outlined, size: 70, color: Colors.grey),
                                SizedBox(height: 12),
                                Text(
                                  'No questions found',
                                  style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          )
                        : Stack(
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

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFF97316) : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                if (_selectedIds.isNotEmpty) {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedIds.remove(question.questionId);
                                    } else {
                                      _selectedIds.add(question.questionId);
                                    }
                                  });
                                } else {
                                  _navigateToUpdateScreen(question);
                                }
                              },
                              onLongPress: () {
                                setState(() {
                                  if (!isSelected) {
                                    _selectedIds.add(question.questionId);
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        _buildStatusBadge(question.status),
                                        const Spacer(),
                                        Text(
                                          'ID: ${question.questionId}',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (_selectedIds.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8),
                                            child: Icon(
                                              isSelected ? Icons.check_circle : Icons.circle_outlined,
                                              color: isSelected ? const Color(0xFFF97316) : Colors.grey[300],
                                              size: 20,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      question.content,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        _buildInfoBadge(question.subjectName, Colors.blue),
                                        const SizedBox(width: 8),
                                        _buildInfoBadge(question.difficulty, _getDiffColor(question.difficulty)),
                                        const Spacer(),
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _navigateToUpdateScreen(question);
                                            } else if (value == 'delete') {
                                              _confirmDelete(question.questionId);
                                            } else if (value == 'publish' && question.status != 'Published') {
                                              context.read<QuestionBloc>().add(PublishQuestionEvent(question.questionId));
                                            } else if (value == 'draft' && question.status != 'Draft') {
                                              context.read<QuestionBloc>().add(DraftQuestionEvent(question.questionId));
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Edit')])),
                                            if (question.status != 'Published')
                                              const PopupMenuItem(value: 'publish', child: Row(children: [Icon(Icons.publish, size: 18), SizedBox(width: 8), Text('Publish')])),
                                            if (question.status != 'Draft')
                                              const PopupMenuItem(value: 'draft', child: Row(children: [Icon(Icons.drafts_outlined, size: 18), SizedBox(width: 8), Text('Move to Draft')])),
                                            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: Colors.red, size: 18), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                                          ],
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

                    if (_selectedIds.isNotEmpty)
                      _buildBottomActions(questions),
                  ],
                ),
              )
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

  Widget _buildBottomActions(List<QuestionModel> questions) {
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

  void _navigateToUpdateScreen(QuestionModel question) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UpdateQuestionScreen(question: question),
      ),
    ).then((_) => _loadQuestions());
  }

  void _confirmDelete(int questionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa câu hỏi?'),
        content: const Text('Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              context.read<QuestionBloc>().add(DeleteQuestionEvent(questionId));
              Navigator.pop(ctx);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
