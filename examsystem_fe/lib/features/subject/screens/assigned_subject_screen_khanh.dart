import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../../core/utils/storage_manager.dart';
import '../bloc/subject_cubit_khanh.dart';
import '../data/subject_api_khanh.dart';
import '../domain/subject_repository_khanh.dart';
import '../models/subject_model_khanh.dart';

class AssignedSubjectScreenKhanh extends StatefulWidget {
  const AssignedSubjectScreenKhanh({super.key});

  @override
  State<AssignedSubjectScreenKhanh> createState() =>
      _AssignedSubjectScreenKhanhState();
}

class _AssignedSubjectScreenKhanhState extends State<AssignedSubjectScreenKhanh> {
  final TextEditingController _searchController = TextEditingController();

  static const Color primaryColor = Color(0xfff15a22);
  static const Color darkColor = Color(0xff183153);
  static const Color backgroundColor = Color(0xfff6f7fb);

  // @override
  // void initState() {
  //   super.initState();
  //
  //   StorageManager.saveTokens(
  //     accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjMiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiTmFtMTIzIiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvZW1haWxhZGRyZXNzIjoibmFtQGdtYWlsLmNvbSIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6IlRlYWNoZXIiLCJleHAiOjE3ODQwMDU2MjgsImlzcyI6IkV4YW1TeXN0ZW0iLCJhdWQiOiJVc2VyRXhhbVN5c3RlbSJ9.cAqxjNom587kb1cofpQPs6EKoUQW3M8Dj1Rgjl8IeKw',
  //     refreshToken: '',
  //   );
  // }

  List<SubjectModelKhanh> _filterSubjects(List<SubjectModelKhanh> subjects) {
    final keyword = _searchController.text.trim().toLowerCase();

    if (keyword.isEmpty) return subjects;

    return subjects.where((subject) {
      return subject.subjectName.toLowerCase().contains(keyword) ||
          (subject.description ?? '').toLowerCase().contains(keyword);
    }).toList();
  }

  void _reload(BuildContext context) {
    context.read<SubjectCubitKhanh>().loadAssignedSubjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubjectCubitKhanh(
        SubjectRepositoryKhanh(SubjectApiKhanh()),
      )..loadAssignedSubjects(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: BlocBuilder<SubjectCubitKhanh, SubjectStateKhanh>(
            builder: (context, state) {
              List<SubjectModelKhanh> subjects = [];

              if (state is SubjectLoadedKhanh) {
                subjects = _filterSubjects(state.subjects);
              }

              return Column(
                children: [
                  _HeaderKhanh(
                    totalCourses: subjects.length,
                    searchController: _searchController,
                    onSearchChanged: () => setState(() {}),
                    onRefresh: () => _reload(context),
                  ),
                  Expanded(
                    child: _buildBody(context, state, subjects),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      SubjectStateKhanh state,
      List<SubjectModelKhanh> subjects,
      ) {
    if (state is SubjectLoadingKhanh) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is SubjectErrorKhanh) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            state.message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (state is SubjectLoadedKhanh) {
      if (subjects.isEmpty) {
        return const Center(
          child: Text(
            'No assigned subjects found',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => _reload(context),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            return _CourseCardKhanh(
              subject: subjects[index],
              index: index,
            );
          },
        ),
      );
    }

    return const SizedBox();
  }
}

class _HeaderKhanh extends StatelessWidget {
  final int totalCourses;
  final TextEditingController searchController;
  final VoidCallback onSearchChanged;
  final VoidCallback onRefresh;

  const _HeaderKhanh({
    required this.totalCourses,
    required this.searchController,
    required this.onSearchChanged,
    required this.onRefresh,
  });

  static const Color primaryColor = Color(0xfff15a22);
  static const Color darkColor = Color(0xff183153);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 6),
            color: Color(0x12000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school, color: primaryColor, size: 22),
              const SizedBox(width: 8),
              const Text(
                'ExamHub Teacher',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, color: darkColor),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'My Assigned Courses',
            style: TextStyle(
              color: darkColor,
              fontSize: 26,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You are teaching $totalCourses course(s).',
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryBoxKhanh(
                  icon: Icons.menu_book_outlined,
                  title: 'TOTAL COURSES',
                  value: totalCourses.toString().padLeft(2, '0'),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: _SummaryBoxKhanh(
                  icon: Icons.assignment_outlined,
                  title: 'STATUS',
                  value: 'Active',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search courses...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  searchController.clear();
                  onSearchChanged();
                },
              ),
              filled: true,
              fillColor: const Color(0xfff6f7fb),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => onSearchChanged(),
          ),
        ],
      ),
    );
  }
}

class _SummaryBoxKhanh extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SummaryBoxKhanh({
    required this.icon,
    required this.title,
    required this.value,
  });

  static const Color primaryColor = Color(0xfff15a22);
  static const Color darkColor = Color(0xff183153);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfffbfbfd),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffeceef4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xffffeee8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 10,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: darkColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
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

class _CourseCardKhanh extends StatelessWidget {
  final SubjectModelKhanh subject;
  final int index;

  const _CourseCardKhanh({
    required this.subject,
    required this.index,
  });

  static const Color primaryColor = Color(0xfff15a22);
  static const Color darkColor = Color(0xff183153);

  @override
  Widget build(BuildContext context) {
    final images = [
      Icons.code,
      Icons.science_outlined,
      Icons.storage_outlined,
      Icons.auto_graph_outlined,
      Icons.computer_outlined,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffeceef4)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, 6),
            color: Color(0x10000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 118,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xffdfe7ea),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              gradient: LinearGradient(
                colors: [
                  const Color(0xffe9eef2),
                  Colors.blueGrey.shade300,
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 22,
                  bottom: 18,
                  child: Icon(
                    images[index % images.length],
                    size: 58,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 14,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'SUB${subject.subjectId}',
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.subjectName,
                  style: const TextStyle(
                    color: darkColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subject.description?.isNotEmpty == true
                      ? subject.description!
                      : 'No description',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.menu_book_outlined,
                        size: 15, color: Colors.blueGrey),
                    const SizedBox(width: 4),
                    const Text(
                      'Subject',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 11),
                    ),
                    const SizedBox(width: 14),
                    Icon(
                      subject.isActive
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                      size: 15,
                      color: subject.isActive ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      subject.isActive ? 'Active' : 'Inactive',
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(subject.subjectName),
                            content: Text(
                              subject.description?.isNotEmpty == true
                                  ? subject.description!
                                  : 'No description',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: darkColor,
                        side: const BorderSide(color: Color(0xffd8c9c1)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: const Text('Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}