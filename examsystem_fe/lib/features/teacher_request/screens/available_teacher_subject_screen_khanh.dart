import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// import '../../../core/utils/storage_manager.dart';
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

  static const Color primaryColor = Color(0xfff15a22);
  static const Color backgroundColor = Color(0xfff6f7fb);
  static const Color textColor = Color(0xff183153);

  // bool _isInitializing = true;
  // String? _initializationError;

  // @override
  // void initState() {
  //   super.initState();
  //   _initializeForTesting();
  // }

  /*
   * Saves a temporary Student token for testing because
   * the login screen has not been implemented yet.
   */
  // Future<void> _initializeForTesting() async {
  //   try {
  //     await StorageManager.saveTokens(
  //       accessToken:
  //       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjQiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiTmhpMTIzIiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvZW1haWxhZGRyZXNzIjoibmhpQGV4YW1wbGUuY29tIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiU3R1ZGVudCIsImV4cCI6MTc4NDAwNTE2NCwiaXNzIjoiRXhhbVN5c3RlbSIsImF1ZCI6IlVzZXJFeGFtU3lzdGVtIn0.eSN2kfIvQ1wy8qhhjwjxdo_FemRWnV6BVH0h2Xejsok',
  //       refreshToken: '',
  //     );
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
   * Opens a dialog where the user enters a reason
   * and optionally selects a certification file.
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
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              title: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xffffeee8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.send_outlined,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Request ${subject.subjectName}',
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reason for registration',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
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
                          fillColor: const Color(0xfff6f7fb),
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
                      const SizedBox(height: 16),
                      const Text(
                        'Certification',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
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

                            if (result == null) return;

                            setDialogState(() {
                              selectedFile = result.files.single;
                              selectedFileName = result.files.single.name;
                            });
                          },
                          icon: Icon(
                            selectedFile == null
                                ? Icons.attach_file
                                : Icons.check_circle_outline,
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
                        const SizedBox(height: 8),
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
                              Icons.close,
                              size: 16,
                            ),
                            label: const Text('Remove file'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    final reason = reasonController.text.trim();

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
                    Icons.send_outlined,
                    size: 18,
                  ),
                  label: const Text('Submit Request'),
                ),
              ],
            );
          },
        );
      },
    );

    reasonController.dispose();
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

  // Widget _buildInitializationError() {
  //   return Scaffold(
  //     backgroundColor: backgroundColor,
  //     body: Center(
  //       child: Padding(
  //         padding: const EdgeInsets.all(24),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Icon(
  //               Icons.error_outline,
  //               color: Colors.red,
  //               size: 48,
  //             ),
  //             const SizedBox(height: 14),
  //             const Text(
  //               'Initialization failed',
  //               style: TextStyle(
  //                 color: textColor,
  //                 fontSize: 19,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //             Text(
  //               _initializationError ?? 'Unknown error',
  //               textAlign: TextAlign.center,
  //               maxLines: 6,
  //               overflow: TextOverflow.ellipsis,
  //               style: const TextStyle(
  //                 color: Colors.red,
  //                 fontSize: 13,
  //               ),
  //             ),
  //             const SizedBox(height: 18),
  //             ElevatedButton.icon(
  //               onPressed: () {
  //                 setState(() {
  //                   _isInitializing = true;
  //                   _initializationError = null;
  //                 });
  //
  //                 _initializeForTesting();
  //               },
  //               icon: const Icon(Icons.refresh),
  //               label: const Text('Retry'),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: primaryColor,
  //                 foregroundColor: Colors.white,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // if (_isInitializing) {
    //   return const Scaffold(
    //     backgroundColor: backgroundColor,
    //     body: Center(
    //       child: CircularProgressIndicator(
    //         color: primaryColor,
    //       ),
    //     ),
    //   );
    // }
    //
    // if (_initializationError != null) {
    //   return _buildInitializationError();
    // }

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
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              title: const Text(
                'Teaching Subjects',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'My teacher requests',
                  onPressed: _openMyRequests,
                  icon: const Icon(
                    Icons.history_outlined,
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh subjects',
                  onPressed: () {
                    _reload(blocContext);
                  },
                  icon: const Icon(
                    Icons.refresh,
                  ),
                ),
              ],
            ),
            body: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 950,
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
                      List<AvailableSubjectRequestModelKhanh>
                      subjects = [];

                      if (state is TeacherRequestLoadedKhanh) {
                        subjects = state.subjects;
                      }

                      if (state is TeacherRequestSubmittingKhanh) {
                        subjects = state.subjects;
                      }

                      if (state is TeacherRequestSuccessKhanh) {
                        subjects = state.subjects;
                      }

                      final filteredSubjects =
                      _filterSubjects(subjects);

                      return Column(
                        children: [
                          _buildHeader(
                            context: context,
                            totalSubjects: filteredSubjects.length,
                          ),
                          const SizedBox(height: 12),
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader({
    required BuildContext context,
    required int totalSubjects,
  }) {
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
            'Available Teaching Subjects',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You can request to teach $totalSubjects subject(s).',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search available subjects...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.close),
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
            onChanged: (_) {
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: _openMyRequests,
              borderRadius: BorderRadius.circular(14),
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.history_outlined,
                      color: Colors.white,
                      size: 19,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'View My Teacher Requests',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      TeacherRequestStateKhanh state,
      List<AvailableSubjectRequestModelKhanh> subjects,
      ) {
    if (state is TeacherRequestLoadingKhanh) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    if (state is TeacherRequestErrorKhanh &&
        subjects.isEmpty) {
      return _ErrorStateKhanh(
        message: state.message,
        onRetry: () {
          _reload(context);
        },
      );
    }

    if (subjects.isEmpty) {
      return _EmptyStateKhanh(
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
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          4,
          16,
          90,
        ),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];

          return _AvailableSubjectCardKhanh(
            subject: subject,
            isSubmitting:
            state is TeacherRequestSubmittingKhanh,
            onRequest: () {
              _showRequestDialog(
                context,
                subject,
              );
            },
          );
        },
      ),
    );
  }
}

class _AvailableSubjectCardKhanh extends StatelessWidget {
  final AvailableSubjectRequestModelKhanh subject;
  final bool isSubmitting;
  final VoidCallback onRequest;

  const _AvailableSubjectCardKhanh({
    required this.subject,
    required this.isSubmitting,
    required this.onRequest,
  });

  static const Color primaryColor = Color(0xfff15a22);
  static const Color textColor = Color(0xff183153);

  @override
  Widget build(BuildContext context) {
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
                text: 'Subject #${subject.subjectId}',
                color: primaryColor,
                background: const Color(0xffffeee8),
              ),
              const Spacer(),
              const _BadgeKhanh(
                text: 'Available',
                color: Colors.green,
                background: Color(0xffe8f8ee),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subject.subjectName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textColor,
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            subject.description?.trim().isNotEmpty == true
                ? subject.description!
                : 'No description available',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 13),
          const Row(
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 16,
                color: Colors.grey,
              ),
              SizedBox(width: 6),
              Text(
                'Teaching subject',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: _ActionButtonKhanh(
              icon: isSubmitting
                  ? Icons.hourglass_top
                  : Icons.send_outlined,
              text: isSubmitting
                  ? 'Submitting...'
                  : 'Send Request',
              onTap: isSubmitting ? null : onRequest,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtonKhanh extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _ActionButtonKhanh({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  static const Color primaryColor = Color(0xfff15a22);

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17,
              color: enabled
                  ? primaryColor
                  : Colors.grey,
            ),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: enabled
                    ? primaryColor
                    : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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

class _EmptyStateKhanh extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyStateKhanh({
    required this.onRefresh,
  });

  static const Color primaryColor = Color(0xfff15a22);
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
          vertical: 80,
        ),
        children: [
          Center(
            child: Container(
              width: 86,
              height: 86,
              decoration: const BoxDecoration(
                color: Color(0xffffeee8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                color: primaryColor,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No available subjects',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'There are currently no subjects available for teaching registration.',
            textAlign: TextAlign.center,
            style: TextStyle(
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

  static const Color primaryColor = Color(0xfff15a22);
  static const Color textColor = Color(0xff183153);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to load subjects',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}