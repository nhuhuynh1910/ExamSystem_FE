  import 'package:file_picker/file_picker.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:go_router/go_router.dart';

  import '../bloc/teacher_request_cubit_khanh.dart';
  import '../data/teacher_request_api_khanh.dart';
  import '../domain/teacher_request_repository_khanh.dart';
  import '../models/available_subject_request_model_khanh.dart';

  class AvailableTeacherSubjectScreenKhanh extends StatefulWidget {
    const AvailableTeacherSubjectScreenKhanh({super.key});

    @override
    State<AvailableTeacherSubjectScreenKhanh> createState() =>
        _AvailableTeacherSubjectScreenKhanhState();
  }

  class _AvailableTeacherSubjectScreenKhanhState
      extends State<AvailableTeacherSubjectScreenKhanh> {
    final TextEditingController _searchController = TextEditingController();

    static const Color primaryColor = Color(0xfff45a24);
    static const Color backgroundColor = Color(0xfff7f8fc);
    static const Color textColor = Color(0xff183153);

    List<AvailableSubjectRequestModelKhanh> _filterSubjects(
        List<AvailableSubjectRequestModelKhanh> subjects,
        ) {
      final keyword = _searchController.text.trim().toLowerCase();

      if (keyword.isEmpty) {
        return subjects;
      }

      return subjects.where((subject) {
        final name = subject.subjectName.toLowerCase();
        final description = (subject.description ?? '').toLowerCase();

        return name.contains(keyword) || description.contains(keyword);
      }).toList();
    }

    /*
     * Opens the teacher request form.
     * The existing Cubit submission logic is preserved.
     */
    Future<void> _showRequestDialog(
        BuildContext cubitContext,
        AvailableSubjectRequestModelKhanh subject,
        ) async {
      final reasonController = TextEditingController();

      PlatformFile? selectedFile;
      String? selectedFileName;
      String? reasonError;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: const Color(0xffffebe4),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.send_outlined,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Teaching Request',
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      subject.subjectName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: textColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Close',
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Reason for registration',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: reasonController,
                            autofocus: true,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText:
                              'Explain why you want to teach this subject...',
                              errorText: reasonError,
                              filled: true,
                              fillColor: backgroundColor,
                              contentPadding: const EdgeInsets.all(14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (_) {
                              if (reasonError != null) {
                                setDialogState(() {
                                  reasonError = null;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 17),
                          const Text(
                            'Certification',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final result =
                                await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: [
                                    'pdf',
                                    'jpg',
                                    'jpeg',
                                    'png',
                                  ],
                                  withData: true,
                                );

                                if (result == null) {
                                  return;
                                }

                                setDialogState(() {
                                  selectedFile = result.files.single;
                                  selectedFileName = result.files.single.name;
                                });
                              },
                              icon: Icon(
                                selectedFile == null
                                    ? Icons.attach_file_rounded
                                    : Icons.check_circle_outline_rounded,
                                size: 19,
                              ),
                              label: Text(
                                selectedFileName ??
                                    'Choose certification file (optional)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: selectedFile == null
                                    ? textColor
                                    : Colors.green,
                                side: BorderSide(
                                  color: selectedFile == null
                                      ? const Color(0xffdfe3ea)
                                      : Colors.green,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          if (selectedFile != null) ...[
                            const SizedBox(height: 5),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  setDialogState(() {
                                    selectedFile = null;
                                    selectedFileName = null;
                                  });
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                ),
                                label: const Text('Remove file'),
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blueGrey,
                                    side: const BorderSide(
                                      color: Color(0xffdfe3ea),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final reason =
                                    reasonController.text.trim();

                                    if (reason.isEmpty) {
                                      setDialogState(() {
                                        reasonError = 'Reason is required.';
                                      });
                                      return;
                                    }

                                    Navigator.pop(dialogContext);

                                    cubitContext
                                        .read<TeacherRequestCubitKhanh>()
                                        .submitRequest(
                                      subjectId: subject.subjectId,
                                      reason: reason,
                                      certificationFile: selectedFile,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.send_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Submit Request',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );

      reasonController.dispose();
    }

    /* Show subject details before submitting a teaching request. */
    void _showSubjectDetail(
        BuildContext cubitContext,
        AvailableSubjectRequestModelKhanh subject,
        ) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (bottomSheetContext) {
          return DraggableScrollableSheet(
            initialChildSize: 0.68,
            minChildSize: 0.48,
            maxChildSize: 0.90,
            expand: false,
            builder: (context, scrollController) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(26),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xffd9dde5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(
                              20,
                              20,
                              20,
                              28,
                            ),
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffffebe4),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.menu_book_outlined,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Subject details',
                                          style: TextStyle(
                                            color: Colors.blueGrey,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          subject.subjectName,
                                          style: const TextStyle(
                                            color: textColor,
                                            fontSize: 19,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Close',
                                    onPressed: () {
                                      Navigator.pop(bottomSheetContext);
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const _SubjectDetailTitleKhanh(
                                icon: Icons.info_outline_rounded,
                                title: 'Subject information',
                              ),
                              const SizedBox(height: 10),
                              _SubjectDetailCardKhanh(
                                children: [
                                  _SubjectDetailRowKhanh(
                                    label: 'Subject ID',
                                    value: subject.subjectId.toString(),
                                  ),
                                  const Divider(height: 24),
                                  _SubjectDetailRowKhanh(
                                    label: 'Subject name',
                                    value: subject.subjectName,
                                  ),
                                  const Divider(height: 24),
                                  _SubjectDetailRowKhanh(
                                    label: 'Description',
                                    value:
                                    subject.description?.trim().isNotEmpty ==
                                        true
                                        ? subject.description!
                                        : 'No description available',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(bottomSheetContext);

                                    _showRequestDialog(
                                      cubitContext,
                                      subject,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.send_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Send Teaching Request',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    void _reload(BuildContext context) {
      context
          .read<TeacherRequestCubitKhanh>()
          .loadAvailableSubjects();
    }

    void _openMyRequests() {
      context.push('/teacher-request/my-requests');
    }

    @override
    void dispose() {
      _searchController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return BlocProvider(
        create: (_) => TeacherRequestCubitKhanh(
          TeacherRequestRepositoryKhanh(
            TeacherRequestApiKhanh(),
          ),
        )..loadAvailableSubjects(),
        child: Builder(
          builder: (blocContext) {
            return Scaffold(
              backgroundColor: backgroundColor,
              appBar: AppBar(
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                foregroundColor: textColor,
                leading: IconButton(
                  tooltip: 'Back',
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/profile');
                    }
                  },
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: primaryColor,
                  ),
                ),
                titleSpacing: 0,
                title: const Text(
                  'Teaching Registration',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: 'My teacher requests',
                    onPressed: _openMyRequests,
                    icon: const Icon(
                      Icons.history_rounded,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh subjects',
                    onPressed: () {
                      _reload(blocContext);
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 4),
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
                      child: BlocConsumer<
                          TeacherRequestCubitKhanh,
                          TeacherRequestStateKhanh>(
                        listener: (context, state) {
                          if (state is TeacherRequestSuccessKhanh) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );

                            context
                                .read<TeacherRequestCubitKhanh>()
                                .loadAvailableSubjects();
                          }

                          if (state is TeacherRequestErrorKhanh) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          List<AvailableSubjectRequestModelKhanh> subjects = [];

                          if (state is TeacherRequestLoadedKhanh) {
                            subjects = state.subjects;
                          } else if (state
                          is TeacherRequestSubmittingKhanh) {
                            subjects = state.subjects;
                          } else if (state is TeacherRequestSuccessKhanh) {
                            subjects = state.subjects;
                          }

                          final filteredSubjects = _filterSubjects(subjects);

                          return Column(
                            children: [
                              _PageHeaderKhanh(
                                searchController: _searchController,
                                onSearchChanged: () {
                                  setState(() {});
                                },
                                onViewRequests: _openMyRequests,
                              ),
                              Expanded(
                                child: _buildBody(
                                  context,
                                  state,
                                  filteredSubjects,
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
        TeacherRequestStateKhanh state,
        List<AvailableSubjectRequestModelKhanh> subjects,
        )
  {
  if
  (
  state
  is
  TeacherRequestLoadingKhanh
  )
  {
  return
  const
  Center
  (
  child
  :
  CircularProgressIndicator
  (
  color
  :
  primaryColor
  ,
  )
  ,
  );
  }

  if
  (
  state
  is
  TeacherRequestErrorKhanh
  &&
  subjects
  .
  isEmpty
  )
  {
  return
  _ErrorStateKhanh
  (
  message
  :
  state
  .
  message
  ,
  onRetry
  :
  (
  )
  {
  _reload
  (
  context
  );
  }
  ,
  );
  }

  if
  (
  subjects
  .
  isEmpty
  )
  {
  return
  _EmptyStateKhanh
  (
  isSearching
  :
  _searchController
  .
  text
  .
  trim
  (
  )
  .
  isNotEmpty
  ,
  onRefresh
  :
  (
  )
  async
  {
  _reload
  (
  context
  );
  }
  ,
  );
  }

  return
  RefreshIndicator
  (
  color
  :
  primaryColor
  ,
  onRefresh
  :
  (
  )
  async
  {
  _reload
  (
  context
  );
  }
  ,
  child
  :
  LayoutBuilder
  (
  builder
  :
  (
  context
  ,
  constraints
  )
  {
    final int columnCount = constraints.maxWidth >= 1200
        ? 3
        : constraints.maxWidth >= 800
        ? 2
        : 1;

  if
  (
  columnCount
  ==
  1
  )
  {
  return
  ListView
  .
  builder
  (
  physics
  :
  const
  AlwaysScrollableScrollPhysics
  (
  )
  ,
  padding
  :
  const
  EdgeInsets
  .
  fromLTRB
  (
  14
  ,
  8
  ,
  14
  ,
  90
  ,
  )
  ,
  itemCount
  :
  subjects
  .
  length
  ,
  itemBuilder
  :
  (
  context
  ,
  index
  )
  {
  final
  subject
  =
  subjects
  [
  index
  ];

  return
  _AvailableSubjectCardKhanh
  (
  subject
  :
  subject
  ,
  isSubmitting
  :
  state
  is
  TeacherRequestSubmittingKhanh
  ,
  onViewDetails
  :
  (
  )
  {
  _showSubjectDetail
  (
  context
  ,
  subject
  ,
  );
  }
  ,
  );
  }
  ,
  );
  }

  return
  GridView
  .
  builder
  (
  physics
  :
  const
  AlwaysScrollableScrollPhysics
  (
  )
  ,
  padding
  :
  const
  EdgeInsets
  .
  fromLTRB
  (
  14
  ,
  8
  ,
  14
  ,
  90
  ,
  )
  ,
  itemCount
  :
  subjects
  .
  length
  ,
  gridDelegate
  :
  SliverGridDelegateWithFixedCrossAxisCount
  (
  crossAxisCount
  :
  columnCount
  ,
  crossAxisSpacing
  :
  14
  ,
  mainAxisSpacing
  :
  14
  ,
  childAspectRatio
  :
  1.45
  ,
  )
  ,
  itemBuilder
  :
  (
  context
  ,
  index
  )
  {
  final
  subject
  =
  subjects
  [
  index
  ];

  return
  _AvailableSubjectCardKhanh
  (
  subject
  :
  subject
  ,
  isSubmitting
  :
  state
  is
  TeacherRequestSubmittingKhanh
  ,
  onViewDetails
  :
  (
  )
  {
  _showSubjectDetail
  (
  context
  ,
  subject
  ,
  );
  }
  ,
  );
  }
  ,
  );
  }
  ,
  )
  ,
  );

  }
  }

  class _PageHeaderKhanh extends StatelessWidget {
    final TextEditingController searchController;
    final VoidCallback onSearchChanged;
    final VoidCallback onViewRequests;

    const _PageHeaderKhanh({
      required this.searchController,
      required this.onSearchChanged,
      required this.onViewRequests,
    });

    static const Color primaryColor = Color(0xfff45a24);
    static const Color textColor = Color(0xff183153);

    @override
    Widget build(BuildContext context) {
      return Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(
          14,
          18,
          14,
          14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Teaching Subjects',
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select a subject and submit your teaching request',
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 11),
            OutlinedButton.icon(
              onPressed: onViewRequests,
              icon: const Icon(
                Icons.history_rounded,
                size: 17,
              ),
              label: const Text(
                'View My Requests',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: const BorderSide(
                  color: primaryColor,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search for subject name...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Colors.blueGrey,
                ),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
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
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(
                    color: Color(0xffffd7c9),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(
                    color: primaryColor,
                    width: 1.4,
                  ),
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

  class _AvailableSubjectCardKhanh extends StatelessWidget {
    final AvailableSubjectRequestModelKhanh subject;
    final bool isSubmitting;
    final VoidCallback onViewDetails;

    const _AvailableSubjectCardKhanh({
      required this.subject,
      required this.isSubmitting,
      required this.onViewDetails,
    });

    static const Color primaryColor = Color(0xfff45a24);
    static const Color textColor = Color(0xff183153);

    @override
    Widget build(BuildContext context) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xffffdcd0),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0d000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _BadgeKhanh(
                  text: 'SUB${subject.subjectId}',
                  color: const Color(0xff637da5),
                  background: const Color(0xffe7edf8),
                ),
                const Spacer(),
                const _AvailableBadgeKhanh(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subject.subjectName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: textColor,
                fontSize: 16,
                height: 1.25,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subject.description?.trim().isNotEmpty == true
                  ? subject.description!
                  : 'No description available',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isSubmitting ? null : onViewDetails,
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 18,
                ),
                label: const Text(
                  'Create Teacher Requests',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  disabledForegroundColor:
                  primaryColor.withValues(alpha: 0.5),
                  side: const BorderSide(
                    color: primaryColor,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  class _AvailableBadgeKhanh extends StatelessWidget {
    const _AvailableBadgeKhanh();

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffddf8e5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.circle,
              size: 6,
              color: Colors.green,
            ),
            SizedBox(width: 4),
            Text(
              'Available',
              style: TextStyle(
                color: Colors.green,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }
  }
  class _SubjectDetailTitleKhanh extends StatelessWidget {
    final IconData icon;
    final String title;

    const _SubjectDetailTitleKhanh({
      required this.icon,
      required this.title,
    });

    static const Color primaryColor = Color(0xfff45a24);
    static const Color textColor = Color(0xff183153);

    @override
    Widget build(BuildContext context) {
      return Row(
        children: [
          Icon(
            icon,
            color: primaryColor,
            size: 19,
          ),
          const SizedBox(width: 7),
          Text(
            title,
            style: const TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      );
    }
  }

  class _SubjectDetailCardKhanh extends StatelessWidget {
    final List<Widget> children;

    const _SubjectDetailCardKhanh({
      required this.children,
    });

    @override
    Widget build(BuildContext context) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xfff7f8fc),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xffe7eaf0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );
    }
  }

  class _SubjectDetailRowKhanh extends StatelessWidget {
    final String label;
    final String value;

    const _SubjectDetailRowKhanh({
      required this.label,
      required this.value,
    });

    static const Color textColor = Color(0xff183153);

    @override
    Widget build(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            style: const TextStyle(
              color: textColor,
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
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
    static const Color textColor = Color(0xff183153);

    @override
    Widget build(BuildContext context) {
      return RefreshIndicator(
        color: primaryColor,
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 70,
          ),
          children: [
            Center(
              child: Container(
                width: 82,
                height: 82,
                decoration: const BoxDecoration(
                  color: Color(0xffffebe4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSearching
                      ? Icons.search_off_rounded
                      : Icons.menu_book_outlined,
                  color: primaryColor,
                  size: 39,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearching
                  ? 'No matching subjects'
                  : 'No available subjects',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textColor,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try searching with another subject name.'
                  : 'There are currently no subjects available for teaching registration.',
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
    static const Color textColor = Color(0xff183153);

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
                'Unable to load subjects',
                style: TextStyle(
                  color: textColor,
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
              const SizedBox(height: 17),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }