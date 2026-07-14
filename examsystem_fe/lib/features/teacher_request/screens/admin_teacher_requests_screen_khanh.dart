import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import '../../../core/utils/storage_manager.dart';
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

  static const Color primaryColor = Color(0xfff15a22);
  static const Color backgroundColor = Color(0xfff6f7fb);
  static const Color textColor = Color(0xff183153);

  String? _status;
  late Future<List<TeacherRequestModelKhanh>> _future;

  // @override
  // void initState() {
  //   super.initState();
  //   _future = _initializeAndLoad();
  // }
  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  /*
   * Saves a temporary Admin token before loading data.
   * Remove this when the login feature is completed.
   */
  // Future<List<TeacherRequestModelKhanh>> _initializeAndLoad() async {
  //   await StorageManager.saveTokens(
  //     accessToken:
  //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjIiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoibGluaDEyMyIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL2VtYWlsYWRkcmVzcyI6ImxpbmhAZ21haWwuY29tIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE3ODQwMDM1NTMsImlzcyI6IkV4YW1TeXN0ZW0iLCJhdWQiOiJVc2VyRXhhbVN5c3RlbSJ9.KJjveCEDjAwEbd6R1HajRI3rwv2q8XqTIXW7051cm8o',
  //     refreshToken: '',
  //   );
  //
  //   return _load();
  // }

  Future<List<TeacherRequestModelKhanh>> _load() {
    return TeacherRequestApiKhanh().getAdminRequests(
      status: _status,
    );
  }

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
      List<TeacherRequestModelKhanh> requests,
      ) {
    final keyword = _searchController.text.trim().toLowerCase();

    if (keyword.isEmpty) {
      return requests;
    }

    return requests.where((request) {
      return request.subjectName.toLowerCase().contains(keyword) ||
          request.studentName.toLowerCase().contains(keyword) ||
          request.studentEmail.toLowerCase().contains(keyword) ||
          (request.reason ?? '').toLowerCase().contains(keyword);
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  Color _statusBackground(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xffe8f8ee);
      case 'rejected':
        return const Color(0xffffe8e8);
      case 'cancelled':
        return const Color(0xffeeeeee);
      default:
        return const Color(0xfffff3e0);
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

  Future<void> _approve(
      TeacherRequestModelKhanh request,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Approve request'),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
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
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _reject(
      TeacherRequestModelKhanh request,
      ) async {
    final noteController = TextEditingController();
    String? errorText;

    final adminNote = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Reject request'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                        fillColor: const Color(0xfff6f7fb),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
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
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDetails(
      TeacherRequestModelKhanh request,
      ) {
    final hasCertificate = request.certificationUrl != null &&
        request.certificationUrl!.trim().isNotEmpty;

    final hasAdminNote =
        request.adminNote != null && request.adminNote!.trim().isNotEmpty;

    final hasReviewer =
        request.reviewerName != null && request.reviewerName!.trim().isNotEmpty;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 560,
              maxHeight: 650,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xffffeee8),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.assignment_outlined,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Request #${request.teacherRequestId}',
                          style: const TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _DetailItemKhanh(
                    label: 'Status',
                    value: request.status,
                  ),
                  _DetailItemKhanh(
                    label: 'Student',
                    value: request.studentName,
                  ),
                  _DetailItemKhanh(
                    label: 'Email',
                    value: request.studentEmail,
                  ),
                  _DetailItemKhanh(
                    label: 'Subject',
                    value: request.subjectName,
                  ),
                  _DetailItemKhanh(
                    label: 'Reason',
                    value: request.reason?.trim().isNotEmpty == true
                        ? request.reason!
                        : 'No reason provided',
                  ),
                  _DetailItemKhanh(
                    label: 'Created date',
                    value: _formatDate(request.createdAt),
                  ),
                  if (hasReviewer)
                    _DetailItemKhanh(
                      label: 'Reviewed by',
                      value: request.reviewerName!,
                    ),
                  if (request.reviewedAt != null)
                    _DetailItemKhanh(
                      label: 'Reviewed date',
                      value: _formatDate(request.reviewedAt),
                    ),
                  if (hasAdminNote)
                    _DetailItemKhanh(
                      label: 'Admin note',
                      value: request.adminNote!,
                    ),
                  if (hasCertificate) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xfff6f7fb),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.attach_file,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Certification attached',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Copy path',
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(
                                  text: request.certificationUrl!,
                                ),
                              );

                              if (!mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Certification path copied.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
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
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage Teacher Requests',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Review, approve or reject teaching requests',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: _reload,
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by student, email or subject...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
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
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _StatusChipKhanh(
                text: 'All',
                active: _status == null,
                onTap: () {
                  _changeStatus(null);
                },
              ),
              _StatusChipKhanh(
                text: 'Pending',
                active: _status?.toLowerCase() == 'pending',
                onTap: () {
                  _changeStatus('Pending');
                },
              ),
              _StatusChipKhanh(
                text: 'Approved',
                active: _status?.toLowerCase() == 'approved',
                onTap: () {
                  _changeStatus('Approved');
                },
              ),
              _StatusChipKhanh(
                text: 'Rejected',
                active: _status?.toLowerCase() == 'rejected',
                onTap: () {
                  _changeStatus('Rejected');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Teacher Requests',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 950,
          ),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildStatusFilter(),
              const SizedBox(height: 10),
              Expanded(
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

                    final requests = _filterRequests(
                      snapshot.data ?? [],
                    );

                    if (requests.isEmpty) {
                      return const Center(
                        child: Text(
                          'No teacher requests found',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: primaryColor,
                      onRefresh: _reload,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          4,
                          16,
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
                      ),
                    );
                  },
                ),
              ),
            ],
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

  static const Color primaryColor = Color(0xfff15a22);
  static const Color textColor = Color(0xff183153);

  @override
  Widget build(BuildContext context) {
    final isPending =
        request.status.toLowerCase() == 'pending';

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
                text: 'Request #${request.teacherRequestId}',
                color: primaryColor,
                background: const Color(0xffffeee8),
              ),
              const Spacer(),
              _BadgeKhanh(
                text: request.status,
                color: statusColor,
                background: statusBackground,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request.subjectName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            request.reason?.trim().isNotEmpty == true
                ? request.reason!
                : 'No reason provided',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  request.studentName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
              const Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: Colors.grey,
              ),
              const SizedBox(width: 5),
              Text(
                createdAt,
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
                icon: Icons.visibility_outlined,
                text: 'View',
                onTap: onView,
              ),
              if (isPending)
                _ActionButtonKhanh(
                  icon: Icons.check_circle_outline,
                  text: 'Approve',
                  color: Colors.green,
                  onTap: onApprove,
                ),
              if (isPending)
                _ActionButtonKhanh(
                  icon: Icons.cancel_outlined,
                  text: 'Reject',
                  color: Colors.redAccent,
                  onTap: onReject,
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

class _DetailItemKhanh extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItemKhanh({
    required this.label,
    required this.value,
  });

  static const Color textColor = Color(0xff183153);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: textColor,
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w700,
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

  static const Color primaryColor = Color(0xfff15a22);
  static const Color textColor = Color(0xff183153);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              'Unable to load requests',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
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
}