import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../bloc/question_cubit_khanh.dart';
import '../data/question_api_khanh.dart';
import '../domain/question_repository_khanh.dart';
import '../models/question_model_khanh.dart';
import '../models/subject_model_khanh.dart';
import 'create_question_screen_khanh.dart';
import 'update_question_screen_khanh.dart';

class QuestionListScreenKhanh extends StatefulWidget {
  const QuestionListScreenKhanh({super.key});

  @override
  State<QuestionListScreenKhanh> createState() =>
      _QuestionListScreenKhanhState();
}

class _QuestionListScreenKhanhState
    extends State<QuestionListScreenKhanh> {
  final TextEditingController _searchController =
  TextEditingController();

  int? _subjectId;
  String? _status;
  String? _difficulty;

  List<SubjectModelKhanh> _subjects = [];
  //
  bool _isInitializing = true;
  String? _initializationError;

  static const Color primaryColor = Color(0xfff15a22);
  static const Color backgroundColor = Color(0xfff6f7fb);
  static const Color textColor = Color(0xff183153);

  // @override
  // void initState() {
  //   super.initState();
  //   _initializeForTesting();
  // }

  /*
   * Saves a temporary JWT token for testing because
   * the login screen has not been implemented yet.
   */
  // Future<void> _initializeForTesting() async {
  //   try {
  //     await StorageManager.saveTokens(
  //       accessToken:
  //       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjEiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoia2hhbmgxMjMiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9lbWFpbGFkZHJlc3MiOiJraGFuaEBnbWFpbC5jb20iLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJUZWFjaGVyIiwiZXhwIjoxNzgzOTkwMTAzLCJpc3MiOiJFeGFtU3lzdGVtIiwiYXVkIjoiVXNlckV4YW1TeXN0ZW0ifQ.3894Pnuxv-HldAQcU1CMD2meg3ibK7oNTlGKtiOuq5c',
  //       refreshToken: '',
  //     );
  //
  //     await _loadSubjects();
  //
  //     if (!mounted) return;
  //
  //     setState(() {
  //       _isInitializing = false;
  //       _initializationError = null;
  //     });
  //   } catch (e) {
  //     if (!mounted) return;
  //
  //     setState(() {
  //       _isInitializing = false;
  //       _initializationError = e.toString();
  //     });
  //   }
  // }
  @override
  void initState() {
    super.initState();
    _initialize();
  }

/* Load required data using the token saved by the login feature. */
  Future<void> _initialize() async {
    try {
      await _loadSubjects();

      if (!mounted) return;

      setState(() {
        _isInitializing = false;
        _initializationError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isInitializing = false;
        _initializationError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /*
   * Loads questions while preserving the selected filters.
   */
  void _loadQuestions(BuildContext context) {
    context.read<QuestionCubitKhanh>().loadQuestions(
      search: _searchController.text.trim(),
      status: _status,
      difficulty: _difficulty,
      subjectId: _subjectId,
    );
  }

  Future<void> _loadSubjects() async {
    final subjects = await QuestionApiKhanh().getSubjects();

    if (!mounted) return;

    setState(() {
      _subjects = subjects;
    });
  }

  Future<void> _confirmDelete({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete question'),
          content: const Text(
            'Are you sure you want to delete this question?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    }

    if (_initializationError != null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Initialization failed',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _initializationError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isInitializing = true;
                      _initializationError = null;
                    });

                    _initialize();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) => QuestionCubitKhanh(
        QuestionRepositoryKhanh(
          QuestionApiKhanh(),
        ),
      )..loadQuestions(),
      child: Builder(
        builder: (blocContext) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              title: const Text(
                'Question Bank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            bottomNavigationBar: _buildQuestionBottomNav(blocContext),
            floatingActionButton: FloatingActionButton(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  blocContext,
                  MaterialPageRoute(
                    builder: (_) =>
                    const CreateQuestionScreenKhanh(),
                  ),
                );

                if (result == true && blocContext.mounted) {
                  _loadQuestions(blocContext);
                }
              },
              child: const Icon(Icons.add),
            ),
            body: Column(
              children: [
                _buildHeader(blocContext),
                const SizedBox(height: 12),
                _buildSubjectFilter(blocContext),
                const SizedBox(height: 10),
                _buildStatusFilter(blocContext),
                const SizedBox(height: 10),
                Expanded(
                  child: _buildQuestionList(blocContext),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manage Questions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Search, publish, draft and delete questions',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search questions...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _searchController.clear();
                  _loadQuestions(context);
                },
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) {
              _loadQuestions(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectFilter(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatusChipKhanh(
                text: 'All Subjects',
                active: _subjectId == null,
                onTap: () {
                  setState(() {
                    _subjectId = null;
                  });

                  _loadQuestions(context);
                },
              ),
              ..._subjects.map(
                    (subject) {
                  return _StatusChipKhanh(
                    text: subject.subjectName,
                    active:
                    _subjectId == subject.subjectId,
                    onTap: () {
                      setState(() {
                        _subjectId = subject.subjectId;
                      });

                      _loadQuestions(context);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilter(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _StatusChipKhanh(
                text: 'All',
                active: _status == null,
                onTap: () {
                  setState(() {
                    _status = null;
                  });

                  _loadQuestions(context);
                },
              ),
              _StatusChipKhanh(
                text: 'Published',
                active:
                _status?.toLowerCase() == 'published',
                onTap: () {
                  setState(() {
                    _status = 'Published';
                  });

                  _loadQuestions(context);
                },
              ),
              _StatusChipKhanh(
                text: 'Draft',
                active: _status?.toLowerCase() == 'draft',
                onTap: () {
                  setState(() {
                    _status = 'Draft';
                  });

                  _loadQuestions(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionList(BuildContext context) {
    return BlocBuilder<QuestionCubitKhanh, QuestionStateKhanh>(
      builder: (context, state) {
        if (state is QuestionLoadingKhanh) {
          return const Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          );
        }

        if (state is QuestionErrorKhanh) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      _loadQuestions(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is QuestionLoadedKhanh) {
          final questions = state.questions;

          if (questions.isEmpty) {
            return const Center(
              child: Text(
                'No questions found',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadQuestions(context);
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                16,
                4,
                16,
                90,
              ),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];

                return _QuestionCardKhanh(
                  question: question,
                  onUpdated: () {
                    _loadQuestions(context);
                  },
                  onDelete: () {
                    _confirmDelete(
                      context: context,
                      onConfirm: () {
                        context
                            .read<QuestionCubitKhanh>()
                            .deleteQuestion(
                          question.questionId,
                        );
                      },
                    );
                  },
                  onPublishDraft: () {
                    final isPublished = question.status
                        .toLowerCase() ==
                        'published';

                    if (isPublished) {
                      context
                          .read<QuestionCubitKhanh>()
                          .draftQuestion(
                        question.questionId,
                      );
                    } else {
                      context
                          .read<QuestionCubitKhanh>()
                          .publishQuestion(
                        question.questionId,
                      );
                    }
                  },
                );
              },
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}

class _QuestionCardKhanh extends StatelessWidget {
  final QuestionModelKhanh question;
  final VoidCallback onDelete;
  final VoidCallback onPublishDraft;
  final VoidCallback onUpdated;

  const _QuestionCardKhanh({
    required this.question,
    required this.onDelete,
    required this.onPublishDraft,
    required this.onUpdated,
  });

  static const Color primaryColor = Color(0xfff15a22);
  static const Color textColor = Color(0xff183153);

  @override
  Widget build(BuildContext context) {
    final isPublished =
        question.status.toLowerCase() == 'published';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _BadgeKhanh(
                text: 'Question #${question.questionId}',
                color: primaryColor,
                background: const Color(0xffffeee8),
              ),
              const Spacer(),
              _BadgeKhanh(
                text: question.status,
                color: isPublished
                    ? Colors.green
                    : Colors.orange,
                background: isPublished
                    ? const Color(0xffe8f8ee)
                    : const Color(0xfffff3e0),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.content,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textColor,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.menu_book_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  question.subjectName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
              const Icon(
                Icons.list_alt,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                '${question.options.length} options',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 14,
            runSpacing: 10,
            children: [
              _ActionButtonKhanh(
                icon: Icons.edit_outlined,
                text: 'Edit',
                onTap: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          UpdateQuestionScreenKhanh(
                            question: question,
                          ),
                    ),
                  );

                  if (result == true && context.mounted) {
                    onUpdated();
                  }
                },
              ),
              _ActionButtonKhanh(
                icon: isPublished
                    ? Icons.visibility_off_outlined
                    : Icons.public_outlined,
                text: isPublished ? 'Draft' : 'Publish',
                onTap: onPublishDraft,
              ),
              _ActionButtonKhanh(
                icon: Icons.delete_outline,
                text: 'Delete',
                onTap: onDelete,
                color: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChipKhanh extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _StatusChipKhanh({
    required this.text,
    required this.active,
    required this.onTap,
  });

  static const Color primaryColor = Color(0xfff15a22);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: active ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? primaryColor
                : const Color(0xffe2e5ec),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active
                ? Colors.white
                : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _BadgeKhanh extends StatelessWidget {
  final String text;
  final Color color;
  final Color background;

  const _BadgeKhanh({
    required this.text,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ActionButtonKhanh extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color color;

  const _ActionButtonKhanh({
    required this.icon,
    required this.text,
    required this.onTap,
    this.color = primaryColor,
  });

  static const Color primaryColor = Color(0xfff15a22);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 5,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildQuestionBottomNav(BuildContext context) {
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
          _QuestionBottomNavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            isActive: false,
            onTap: () => context.go(AppRouter.featureHub),
          ),
          _QuestionBottomNavItem(
            icon: Icons.quiz_rounded,
            label: 'Questions',
            isActive: true,
            onTap: () {},
          ),
          _QuestionBottomNavItem(
            icon: Icons.assignment_rounded,
            label: 'Exams',
            isActive: false,
            onTap: () => context.go(AppRouter.examList),
          ),
          _QuestionBottomNavItem(
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

class _QuestionBottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _QuestionBottomNavItem({
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