import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/teacher_request_api_khanh.dart';
import '../models/teacher_request_model_khanh.dart';

class AdminTeacherRequestsScreenKhanh extends StatefulWidget {
  const AdminTeacherRequestsScreenKhanh({super.key});

  @override
  State<AdminTeacherRequestsScreenKhanh> createState() =>
      _AdminTeacherRequestsScreenKhanhState();
}

class _AdminTeacherRequestsScreenKhanhState
    extends State<AdminTeacherRequestsScreenKhanh> {
  final TextEditingController _searchController = TextEditingController();

  static const Color primaryColor = Color(0xfff45a24);
  static const Color backgroundColor = Color(0xfff7f8fc);
  static const Color textColor = Color(0xff183153);

  String? _status;
  late Future<List<TeacherRequestModelKhanh>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  /* Load teacher requests using the current status filter. */
  Future<List<TeacherRequestModelKhanh>> _load() {
    return TeacherRequestApiKhanh().getAdminRequests(
      status: _status,
    );
  }

  /* Reload the request list from the backend. */
  Future<void> _reload() async {
    final newFuture = _load();

    setState(() {
      _future = newFuture;
    });

    await newFuture;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TeacherRequestModelKhanh> _filterRequests(
      List<TeacherRequestModelKhanh> requests,) {
    final keyword = _searchController.text.trim().toLowerCase();

    if (keyword.isEmpty) {
      return requests;
    }

    return requests.where((request) {
      final id = request.teacherRequestId.toString();
      final subjectName = request.subjectName.toLowerCase();
      final studentName = request.studentName.toLowerCase();
      final studentEmail = request.studentEmail.toLowerCase();
      final reason = (request.reason ?? '').toLowerCase();
      final status = request.status.toLowerCase();

      return id.contains(keyword) ||
          subjectName.contains(keyword) ||
          studentName.contains(keyword) ||
          studentEmail.contains(keyword) ||
          reason.contains(keyword) ||
          status.contains(keyword);
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xff25a84c);

      case 'rejected':
        return const Color(0xffe5484d);

      case 'cancelled':
        return Colors.grey;

      default:
        return const Color(0xffff8a00);
    }
  }

  Color _statusBackground(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xffe5f8eb);

      case 'rejected':
        return const Color(0xffffe8e8);

      case 'cancelled':
        return const Color(0xffeeeeee);

      default:
        return const Color(0xfffff1df);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_outline_rounded;

      case 'rejected':
        return Icons.cancel_outlined;

      case 'cancelled':
        return Icons.remove_circle_outline;

      default:
        return Icons.schedule_rounded;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'N/A';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void _changeStatus(String? status) {
    setState(() {
      _status = status;
      _future = _load();
    });
  }

  /* Confirm and approve a pending teacher request. */
  Future<void> _approve(TeacherRequestModelKhanh request,) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.green,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text('Approve request'),
              ),
            ],
          ),
          content: Text(
            'Approve the request for "${request.subjectName}" '
                'from ${request.studentName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await TeacherRequestApiKhanh().approveRequest(
        request.teacherRequestId,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request approved successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await _reload();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /* Reject a pending request with a required Admin note. */
  Future<void> _reject(TeacherRequestModelKhanh request,) async {
    final noteController = TextEditingController();
    String? errorText;

    final adminNote = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    color: Colors.red,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text('Reject request'),
                  ),
                ],
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reject "${request.subjectName}" from '
                          '${request.studentName}.',
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: noteController,
                      autofocus: true,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Admin note',
                        hintText: 'Enter rejection reason...',
                        errorText: errorText,
                        filled: true,
                        fillColor: backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (_) {
                        if (errorText != null) {
                          setDialogState(() {
                            errorText = null;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final note = noteController.text.trim();

                    if (note.isEmpty) {
                      setDialogState(() {
                        errorText = 'Rejection reason is required.';
                      });
                      return;
                    }

                    Navigator.pop(dialogContext, note);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Reject'),
                ),
              ],
            );
          },
        );
      },
    );

    noteController.dispose();

    if (adminNote == null) {
      return;
    }

    try {
      await TeacherRequestApiKhanh().rejectRequest(
        requestId: request.teacherRequestId,
        adminNote: adminNote,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request rejected successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await _reload();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /* Show complete teacher request details. */
  void _showDetails(TeacherRequestModelKhanh request,) {
    final bool hasCertificate = request.certificationUrl != null &&
        request.certificationUrl!.trim().isNotEmpty;

    final bool hasAdminNote =
        request.adminNote != null && request.adminNote!.trim().isNotEmpty;

    final bool hasReviewer =
        request.reviewerName != null && request.reviewerName!.trim().isNotEmpty;

    final bool isPending =
        request.status.toLowerCase() == 'pending';

    final Color statusColor = _statusColor(request.status);
    final Color statusBackground =
    _statusBackground(request.status);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.86,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 680,
                ),
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
                            32,
                          ),
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
                                    Icons.admin_panel_settings_outlined,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Request #'
                                            '${request.teacherRequestId}',
                                        style: const TextStyle(
                                          color: textColor,
                                          fontSize: 19,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      const Text(
                                        'Teacher request details',
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 12,
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
                                  icon: const Icon(
                                    Icons.close_rounded,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: statusBackground,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _statusIcon(request.status),
                                    color: statusColor,
                                    size: 21,
                                  ),
                                  const SizedBox(width: 9),
                                  const Text(
                                    'Current status',
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    request.status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 21),
                            const _DetailTitleKhanh(
                              icon: Icons.person_outline_rounded,
                              title: 'Student information',
                            ),
                            const SizedBox(height: 10),
                            _DetailCardKhanh(
                              children: [
                                _DetailRowKhanh(
                                  label: 'Student name',
                                  value: request.studentName,
                                ),
                                const Divider(height: 24),
                                _DetailRowKhanh(
                                  label: 'Email',
                                  value: request.studentEmail,
                                ),
                              ],
                            ),
                            const SizedBox(height: 21),
                            const _DetailTitleKhanh(
                              icon: Icons.menu_book_outlined,
                              title: 'Request information',
                            ),
                            const SizedBox(height: 10),
                            _DetailCardKhanh(
                              children: [
                                _DetailRowKhanh(
                                  label: 'Subject',
                                  value: request.subjectName,
                                ),
                                const Divider(height: 24),
                                _DetailRowKhanh(
                                  label: 'Reason',
                                  value:
                                  request.reason
                                      ?.trim()
                                      .isNotEmpty ==
                                      true
                                      ? request.reason!
                                      : 'No reason provided',
                                ),
                                const Divider(height: 24),
                                _DetailRowKhanh(
                                  label: 'Created date',
                                  value: _formatDate(request.createdAt),
                                ),
                              ],
                            ),
                            if (hasReviewer ||
                                request.reviewedAt != null) ...[
                              const SizedBox(height: 21),
                              const _DetailTitleKhanh(
                                icon: Icons.fact_check_outlined,
                                title: 'Review information',
                              ),
                              const SizedBox(height: 10),
                              _DetailCardKhanh(
                                children: [
                                  if (hasReviewer)
                                    _DetailRowKhanh(
                                      label: 'Reviewed by',
                                      value: request.reviewerName!,
                                    ),
                                  if (hasReviewer &&
                                      request.reviewedAt != null)
                                    const Divider(height: 24),
                                  if (request.reviewedAt != null)
                                    _DetailRowKhanh(
                                      label: 'Reviewed date',
                                      value: _formatDate(
                                        request.reviewedAt,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                            if (hasAdminNote) ...[
                              const SizedBox(height: 21),
                              const _DetailTitleKhanh(
                                icon: Icons.info_outline_rounded,
                                title: 'Admin note',
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xfffff7f2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xffffd7c7),
                                  ),
                                ),
                                child: Text(
                                  request.adminNote!,
                                  style: const TextStyle(
                                    color: textColor,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                            if (hasCertificate) ...[
                              const SizedBox(height: 21),
                              const _DetailTitleKhanh(
                                icon: Icons.attach_file_rounded,
                                title: 'Certification',
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xffe5e8ef),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xffffebe4),
                                        borderRadius:
                                        BorderRadius.circular(11),
                                      ),
                                      child: const Icon(
                                        Icons.description_outlined,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 11),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Certification attached',
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          SizedBox(height: 3),
                                          Text(
                                            'Copy certification path',
                                            style: TextStyle(
                                              color: Colors.blueGrey,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Copy certification path',
                                      onPressed: () async {
                                        await Clipboard.setData(
                                          ClipboardData(
                                            text:
                                            request.certificationUrl!,
                                          ),
                                        );

                                        if (!mounted) {
                                          return;
                                        }

                                        ScaffoldMessenger.of(
                                          this.context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Certification path copied.',
                                            ),
                                            behavior:
                                            SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.copy_outlined,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (isPending) ...[
                              const SizedBox(height: 22),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          bottomSheetContext,
                                        );

                                        _reject(request);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(
                                          color: Colors.red,
                                        ),
                                        padding:
                                        const EdgeInsets.symmetric(
                                          vertical: 13,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(11),
                                        ),
                                      ),
                                      child: const Text(
                                        'Reject',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          bottomSheetContext,
                                        );

                                        _approve(request);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding:
                                        const EdgeInsets.symmetric(
                                          vertical: 13,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(11),
                                        ),
                                      ),
                                      child: const Text(
                                        'Approve',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: textColor,
        title: const Text(
          'Teacher Requests',
          style: TextStyle(
            color: primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh requests',
            onPressed: _reload,
            icon: const Icon(
              Icons.refresh_rounded,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 5),
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
              child: FutureBuilder<List<TeacherRequestModelKhanh>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _ErrorStateKhanh(
                      message: snapshot.error.toString(),
                      onRetry: _reload,
                    );
                  }

                  final allRequests = snapshot.data ?? [];
                  final requests = _filterRequests(allRequests);

                  return Column(
                    children: [
                      _AdminHeaderKhanh(
                        searchController: _searchController,
                        onSearchChanged: () {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 10),
                      _StatusFilterKhanh(
                        selectedStatus: _status,
                        onChanged: _changeStatus,
                      ),
                      const SizedBox(height: 9),
                      Expanded(
                        child: allRequests.isEmpty
                            ? _EmptyStateKhanh(
                          isSearching: false,
                          selectedStatus: _status,
                          onRefresh: _reload,
                        )
                            : requests.isEmpty
                            ? _EmptyStateKhanh(
                          isSearching: true,
                          selectedStatus: _status,
                          onRefresh: _reload,
                        )
                            : RefreshIndicator(
                          color: primaryColor,
                          onRefresh: _reload,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final int columnCount =
                              constraints.maxWidth >= 1200
                                  ? 3
                                  : constraints.maxWidth >= 800
                                  ? 2
                                  : 1;

                              if (columnCount == 1) {
                                return ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    5,
                                    12,
                                    90,
                                  ),
                                  itemCount: requests.length,
                                  itemBuilder: (context, index) {
                                    final request = requests[index];

                                    return _TeacherRequestCardKhanh(
                                      request: request,
                                      statusColor: _statusColor(request.status),
                                      statusBackground:
                                      _statusBackground(request.status),
                                      createdAt: _formatDate(request.createdAt),
                                      onView: () {
                                        _showDetails(request);
                                      },
                                      onApprove: () {
                                        _approve(request);
                                      },
                                      onReject: () {
                                        _reject(request);
                                      },
                                    );
                                  },
                                );
                              }

                              return GridView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  5,
                                  12,
                                  90,
                                ),
                                itemCount: requests.length,
                                gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columnCount,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 1.45,
                                ),
                                itemBuilder: (context, index) {
                                  final request = requests[index];

                                  return _TeacherRequestCardKhanh(
                                    request: request,
                                    statusColor: _statusColor(request.status),
                                    statusBackground:
                                    _statusBackground(request.status),
                                    createdAt: _formatDate(request.createdAt),
                                    onView: () {
                                      _showDetails(request);
                                    },
                                    onApprove: () {
                                      _approve(request);
                                    },
                                    onReject: () {
                                      _reject(request);
                                    },
                                  );
                                },
                              );
                            },
                          ),
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
  }
}
class _AdminHeaderKhanh extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onSearchChanged;

  const _AdminHeaderKhanh({
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        0,
      ),
      child: TextField(
        controller: searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search student, email, or subject...',
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
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
              size: 19,
            ),
          ),
          filled: true,
          fillColor: const Color(0xfff3f5f9),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 11,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (_) {
          onSearchChanged();
        },
      ),
    );
  }
}

class _StatusFilterKhanh extends StatelessWidget {
  final String? selectedStatus;
  final ValueChanged<String?> onChanged;

  const _StatusFilterKhanh({
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 37,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        children: [
          _StatusChipKhanh(
            text: 'All',
            active: selectedStatus == null,
            activeColor: const Color(0xffb83f09),
            onTap: () {
              onChanged(null);
            },
          ),
          _StatusChipKhanh(
            text: 'Pending',
            active:
            selectedStatus?.toLowerCase() == 'pending',
            activeColor: const Color(0xffff8a00),
            onTap: () {
              onChanged('Pending');
            },
          ),
          _StatusChipKhanh(
            text: 'Approved',
            active:
            selectedStatus?.toLowerCase() == 'approved',
            activeColor: const Color(0xff25a84c),
            onTap: () {
              onChanged('Approved');
            },
          ),
          _StatusChipKhanh(
            text: 'Rejected',
            active:
            selectedStatus?.toLowerCase() == 'rejected',
            activeColor: const Color(0xffe5484d),
            onTap: () {
              onChanged('Rejected');
            },
          ),
        ],
      ),
    );
  }
}

class _StatusChipKhanh extends StatelessWidget {
  final String text;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _StatusChipKhanh({
    required this.text,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: Material(
        color: active
            ? activeColor
            : const Color(0xffedf1f7),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 8,
            ),
            child: Text(
              text,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : Colors.blueGrey,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TeacherRequestCardKhanh extends StatelessWidget {
  final TeacherRequestModelKhanh request;
  final Color statusColor;
  final Color statusBackground;
  final String createdAt;
  final VoidCallback onView;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _TeacherRequestCardKhanh({
    required this.request,
    required this.statusColor,
    required this.statusBackground,
    required this.createdAt,
    required this.onView,
    required this.onApprove,
    required this.onReject,
  });

  static const Color primaryColor = Color(0xfff45a24);
  static const Color textColor = Color(0xff183153);

  @override
  Widget build(BuildContext context) {
    final bool isPending =
        request.status.toLowerCase() == 'pending';

    final String firstLetter = request.studentName
        .trim()
        .isNotEmpty
        ? request.studentName.trim()[0].toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xffffdcd0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0d000000),
            blurRadius: 9,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#REQ-${request.teacherRequestId.toString().padLeft(4, '0')}',
                style: const TextStyle(
                  color: Color(0xff637da5),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              _RequestStatusBadgeKhanh(
                text: request.status,
                color: statusColor,
                background: statusBackground,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            request.subjectName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textColor,
              fontSize: 15,
              height: 1.3,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xffffebe4),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.studentEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          const Text(
            'REASON',
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            request.reason?.trim().isNotEmpty == true
                ? '"${request.reason!}"'
                : '"No reason provided"',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 11,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 11),
          const Divider(
            height: 1,
            color: Color(0xffffe5dc),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Created: $createdAt',
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 9,
                  ),
                ),
              ),
              _SmallActionButtonKhanh(
                text: 'View',
                foregroundColor: const Color(0xff637da5),
                borderColor: const Color(0xff9dafca),
                onTap: onView,
              ),
              if (isPending) ...[
                const SizedBox(width: 6),
                _SmallActionButtonKhanh(
                  text: 'Approve',
                  backgroundColor: const Color(0xff25a84c),
                  foregroundColor: Colors.white,
                  borderColor: const Color(0xff25a84c),
                  onTap: onApprove,
                ),
                const SizedBox(width: 6),
                _SmallActionButtonKhanh(
                  text: 'Reject',
                  backgroundColor: const Color(0xffe5484d),
                  foregroundColor: Colors.white,
                  borderColor: const Color(0xffe5484d),
                  onTap: onReject,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallActionButtonKhanh extends StatelessWidget {
  final String text;
  final Color foregroundColor;
  final Color borderColor;
  final Color? backgroundColor;
  final VoidCallback onTap;

  const _SmallActionButtonKhanh({
    required this.text,
    required this.foregroundColor,
    required this.borderColor,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.white,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestStatusBadgeKhanh extends StatelessWidget {
  final String text;
  final Color color;
  final Color background;

  const _RequestStatusBadgeKhanh({
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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DetailTitleKhanh extends StatelessWidget {
  final IconData icon;
  final String title;

  const _DetailTitleKhanh({
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
          size: 19,
          color: primaryColor,
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

class _DetailCardKhanh extends StatelessWidget {
  final List<Widget> children;

  const _DetailCardKhanh({
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

class _DetailRowKhanh extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRowKhanh({
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

class _EmptyStateKhanh extends StatelessWidget {
  final bool isSearching;
  final String? selectedStatus;
  final Future<void> Function() onRefresh;

  const _EmptyStateKhanh({
    required this.isSearching,
    required this.selectedStatus,
    required this.onRefresh,
  });

  static const Color primaryColor = Color(0xfff45a24);
  static const Color textColor = Color(0xff183153);

  @override
  Widget build(BuildContext context) {
    final String message;

    if (isSearching) {
      message = 'No teacher requests match your search.';
    } else if (selectedStatus != null) {
      message =
      'No ${selectedStatus!.toLowerCase()} teacher requests found.';
    } else {
      message = 'No teacher requests found.';
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 75,
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
                    : Icons.inbox_outlined,
                color: primaryColor,
                size: 39,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No requests available',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
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
  final Future<void> Function() onRetry;

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
              'Unable to load requests',
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
              icon: const Icon(
                Icons.refresh_rounded,
              ),
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