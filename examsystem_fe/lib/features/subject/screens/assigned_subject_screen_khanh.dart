  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';

  import '../bloc/subject_cubit_khanh.dart';
  import '../data/subject_api_khanh.dart';
  import '../domain/subject_repository_khanh.dart';
  import '../models/subject_model_khanh.dart';
  import 'package:go_router/go_router.dart';

  class AssignedSubjectScreenKhanh extends StatefulWidget {
    const AssignedSubjectScreenKhanh({super.key});

    @override
    State<AssignedSubjectScreenKhanh> createState() =>
        _AssignedSubjectScreenKhanhState();
  }

  class _AssignedSubjectScreenKhanhState
      extends State<AssignedSubjectScreenKhanh> {
    final TextEditingController _searchController =
    TextEditingController();

    static const Color primaryColor = Color(0xfff45a24);
    static const Color darkColor = Color(0xff183153);
    static const Color backgroundColor = Color(0xfff7f8fc);

    List<SubjectModelKhanh> _filterSubjects(
        List<SubjectModelKhanh> subjects,
        ) {
      final keyword = _searchController.text
          .trim()
          .toLowerCase();

      if (keyword.isEmpty) {
        return subjects;
      }

      return subjects.where((subject) {
        final subjectName =
        subject.subjectName.toLowerCase();

        final description =
        (subject.description ?? '').toLowerCase();

        return subjectName.contains(keyword) ||
            description.contains(keyword);
      }).toList();
    }

    /* Reload assigned subjects from the server. */
    void _reload(BuildContext context) {
      context
          .read<SubjectCubitKhanh>()
          .loadAssignedSubjects();
    }

    /* Show complete information of an assigned subject. */
    void _showSubjectDetails(
        BuildContext context,
        SubjectModelKhanh subject,
        ) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xffffebe4),
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.menu_book_outlined,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            subject.subjectName,
                            style: const TextStyle(
                              color: darkColor,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _DetailItemKhanh(
                      label: 'Subject ID',
                      value:
                      'SUB${subject.subjectId}',
                    ),
                    _DetailItemKhanh(
                      label: 'Subject name',
                      value: subject.subjectName,
                    ),
                    _DetailItemKhanh(
                      label: 'Description',
                      value: subject.description
                          ?.trim()
                          .isNotEmpty ==
                          true
                          ? subject.description!
                          : 'No description available',
                    ),
                    _DetailItemKhanh(
                      label: 'Status',
                      value: subject.isActive
                          ? 'Active'
                          : 'Inactive',
                      valueColor: subject.isActive
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding:
                          const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
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
          SubjectRepositoryKhanh(
            SubjectApiKhanh(),
          ),
        )..loadAssignedSubjects(),
        child: Builder(
          builder: (blocContext) {
            return Scaffold(
              backgroundColor: backgroundColor,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: darkColor,
                surfaceTintColor: Colors.white,
                leading: Navigator.of(context).canPop()
                    ? IconButton(
                  tooltip: 'Back',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                  ),
                )
                    : null,
                title: const Text(
                  'Assigned Subjects',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: 'Refresh subjects',
                    onPressed: () {
                      _reload(blocContext);
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: darkColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ),
              body: SafeArea(
                top: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isDesktop = constraints.maxWidth >= 900;

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 28 : 0,
                      ),
                      child: BlocBuilder<
                          SubjectCubitKhanh,
                          SubjectStateKhanh>(
                        builder: (context, state) {
                          List<SubjectModelKhanh> subjects = [];

                          if (state is SubjectLoadedKhanh) {
                            subjects = _filterSubjects(
                              state.subjects,
                            );
                          }

                          return Column(
                            children: [
                              _PortfolioHeaderKhanh(
                                totalSubjects: subjects.length,
                                searchController: _searchController,
                                onSearchChanged: () {
                                  setState(() {});
                                },
                                onRequestAdditionalSubject: () {
                                  context.push(
                                    '/teacher-request/available-subjects',
                                  );
                                },
                              ),
                              Expanded(
                                child: _buildBody(
                                  context,
                                  state,
                                  subjects,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      );
    }

    Widget _buildBody(
        BuildContext context,
        SubjectStateKhanh state,
        List<SubjectModelKhanh> subjects,
        ) {
      if (state is SubjectLoadingKhanh) {
        return const Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        );
      }

      if (state is SubjectErrorKhanh) {
        return _ErrorStateKhanh(
          message: state.message,
          onRetry: () {
            _reload(context);
          },
        );
      }

      if (state is SubjectLoadedKhanh) {
        if (subjects.isEmpty) {
          return _EmptyStateKhanh(
            isSearching:
            _searchController.text.trim().isNotEmpty,
            onRefresh: () async {
              _reload(context);
            },
          );
        }

  return RefreshIndicator(
  color: primaryColor,
  onRefresh: () async {
  _reload(context);
  },
  child: LayoutBuilder(
  builder: (context, constraints) {
  final int columnCount = constraints.maxWidth >= 1200
  ? 3
  : constraints.maxWidth >= 800
  ? 2
  : 1;

  if (columnCount == 1) {
  return ListView.builder(
  physics: const AlwaysScrollableScrollPhysics(),
  padding: const EdgeInsets.fromLTRB(
  16,
  10,
  16,
  100,
  ),
  itemCount: subjects.length + 1,
  itemBuilder: (context, index) {
  if (index == subjects.length) {
  return const _ManagedNoticeKhanh();
  }

  final subject = subjects[index];

  return _AssignedSubjectCardKhanh(
  subject: subject,
  onViewDetails: () {
  _showSubjectDetails(
  context,
  subject,
  );
  },
  );
  },
  );
  }

  return CustomScrollView(
  physics: const AlwaysScrollableScrollPhysics(),
  slivers: [
  SliverPadding(
  padding: const EdgeInsets.fromLTRB(
  16,
  10,
  16,
  20,
  ),
  sliver: SliverGrid(
  delegate: SliverChildBuilderDelegate(
  (context, index) {
  final subject = subjects[index];

  return _AssignedSubjectCardKhanh(
  subject: subject,
  onViewDetails: () {
  _showSubjectDetails(
  context,
  subject,
  );
  },
  );
  },
  childCount: subjects.length,
  ),
  gridDelegate:
  SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: columnCount,
  crossAxisSpacing: 14,
  mainAxisSpacing: 14,
  childAspectRatio: 1.35,
  ),
  ),
  ),
  const SliverToBoxAdapter(
  child: _ManagedNoticeKhanh(),
  ),
  const SliverToBoxAdapter(
  child: SizedBox(height: 80),
  ),
  ],
  );
  },
  ),
  );
      }

      return const SizedBox();
    }
  }

  class _PortfolioHeaderKhanh extends StatelessWidget {
    final int totalSubjects;
    final TextEditingController searchController;
    final VoidCallback onSearchChanged;
    final VoidCallback onRequestAdditionalSubject;

    const _PortfolioHeaderKhanh({
      required this.totalSubjects,
      required this.searchController,
      required this.onSearchChanged,
      required this.onRequestAdditionalSubject,
    });

    static const Color primaryColor = Color(0xfff45a24);
    static const Color darkColor = Color(0xff183153);

    @override
    Widget build(BuildContext context) {
      return Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(
          16,
          14,
          16,
          16,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Your Portfolio',
                    style: TextStyle(
                      color: darkColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffffebe4),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$totalSubjects assigned',
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Subjects assigned to your teaching account.',
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRequestAdditionalSubject,
                icon: const Icon(
                  Icons.add_rounded,
                  size: 18,
                ),
                label: const Text(
                  'Request Additional Subject',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: searchController,
              textInputAction:
              TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search assigned subjects...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                ),
                suffixIcon: IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    searchController.clear();
                    onSearchChanged();
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                ),
                filled: true,
                fillColor: const Color(0xfff6f7fb),
                contentPadding:
                const EdgeInsets.symmetric(
                  vertical: 11,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) {
                onSearchChanged();
              },
            ),
          ],
        ),
      );
    }
  }

  class _AssignedSubjectCardKhanh
      extends StatelessWidget {
    final SubjectModelKhanh subject;
    final VoidCallback onViewDetails;

    const _AssignedSubjectCardKhanh({
      required this.subject,
      required this.onViewDetails,
    });

    static const Color primaryColor = Color(0xfff45a24);
    static const Color darkColor = Color(0xff183153);

    @override
    Widget build(BuildContext context) {
      final bool isActive = subject.isActive;

      return Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: const Color(0xffe8eaf0),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0d000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'SUB${subject.subjectId}',
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                _StatusBadgeKhanh(
                  text: isActive
                      ? 'Active'
                      : 'Inactive',
                  color: isActive
                      ? Colors.green
                      : Colors.orange,
                  background: isActive
                      ? const Color(0xffe9f8ee)
                      : const Color(0xfffff3df),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subject.subjectName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: darkColor,
                fontSize: 16,
                height: 1.3,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              subject.description
                  ?.trim()
                  .isNotEmpty ==
                  true
                  ? subject.description!
                  : 'No description available',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 12,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  size: 15,
                  color: Colors.blueGrey,
                ),
                const SizedBox(width: 5),
                const Text(
                  'Assigned teaching subject',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                Icon(
                  isActive
                      ? Icons.check_circle_outline
                      : Icons.pause_circle_outline,
                  color: isActive
                      ? Colors.green
                      : Colors.orange,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: isActive
                  ? ElevatedButton.icon(
                onPressed: onViewDetails,
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                ),
                label: const Text(
                  'View Details',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  primaryColor,
                  foregroundColor:
                  Colors.white,
                  elevation: 0,
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                ),
              )
                  : OutlinedButton.icon(
                onPressed: onViewDetails,
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 17,
                ),
                label: const Text(
                  'View Details',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                style:
                OutlinedButton.styleFrom(
                  foregroundColor:
                  Colors.blueGrey,
                  side: const BorderSide(
                    color: Color(0xffcfd5df),
                  ),
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  class _StatusBadgeKhanh extends StatelessWidget {
    final String text;
    final Color color;
    final Color background;

    const _StatusBadgeKhanh({
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
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }
  }

  class _DetailItemKhanh extends StatelessWidget {
    final String label;
    final String value;
    final Color? valueColor;

    const _DetailItemKhanh({
      required this.label,
      required this.value,
      this.valueColor,
    });

    static const Color darkColor = Color(0xff183153);

    @override
    Widget build(BuildContext context) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xfff7f8fc),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? darkColor,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }
  }

  class _ManagedNoticeKhanh extends StatelessWidget {
    const _ManagedNoticeKhanh();

    static const Color primaryColor = Color(0xfff45a24);

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          22,
          16,
          10,
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xffffebe4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_outlined,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Assigned subjects are managed by the Academic Department',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 11,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
  }

  class _EmptyStateKhanh extends StatelessWidget {
    final bool isSearching;
    final Future<void> Function() onRefresh;

    const _EmptyStateKhanh({
      required this.isSearching,
      required this.onRefresh,
    });

    static const Color primaryColor = Color(0xfff45a24);
    static const Color darkColor = Color(0xff183153);

    @override
    Widget build(BuildContext context) {
      return RefreshIndicator(
        color: primaryColor,
        onRefresh: onRefresh,
        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 80,
          ),
          children: [
            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  color: Color(0xffffebe4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSearching
                      ? Icons.search_off_rounded
                      : Icons.menu_book_outlined,
                  color: primaryColor,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearching
                  ? 'No matching subjects'
                  : 'No assigned subjects',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: darkColor,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try searching with another subject name.'
                  : 'You have not been assigned to any teaching subjects yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }
  }

  class _ErrorStateKhanh extends StatelessWidget {
    final String message;
    final VoidCallback onRetry;

    const _ErrorStateKhanh({
      required this.message,
      required this.onRetry,
    });

    static const Color primaryColor = Color(0xfff45a24);
    static const Color darkColor = Color(0xff183153);

    @override
    Widget build(BuildContext context) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 14),
              const Text(
                'Unable to load assigned subjects',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }