import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// import '../../../core/utils/storage_manager.dart';
import '../data/teacher_request_api_khanh.dart';
import '../models/teacher_request_model_khanh.dart';

class MyTeacherRequestsScreenKhanh extends StatefulWidget {
  const MyTeacherRequestsScreenKhanh({super.key});

  @override
  State<MyTeacherRequestsScreenKhanh> createState() =>
      _MyTeacherRequestsScreenKhanhState();
}

class _MyTeacherRequestsScreenKhanhState
    extends State<MyTeacherRequestsScreenKhanh> {
  static const Color primaryColor = Color(0xfff15a22);
  static const Color backgroundColor = Color(0xfff6f7fb);
  static const Color darkColor = Color(0xff183153);

  late Future<List<TeacherRequestModelKhanh>> _future;

  // @override
  // void initState() {
  //   super.initState();
  //   _future = _initializeAndLoad();
  // }
  @override
  void initState() {
    super.initState();
    _future = TeacherRequestApiKhanh().getMyRequests();
  }

  /* Save temporary token before loading requests. */
  // Future<List<TeacherRequestModelKhanh>> _initializeAndLoad() async {
  //   await StorageManager.saveTokens(
  //     accessToken:
  //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjQiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiTmhpMTIzIiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvZW1haWxhZGRyZXNzIjoibmhpQGV4YW1wbGUuY29tIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiU3R1ZGVudCIsImV4cCI6MTc4NDAwNDYyMSwiaXNzIjoiRXhhbVN5c3RlbSIsImF1ZCI6IlVzZXJFeGFtU3lzdGVtIn0.X0eXiiURlxl7FI32-AEZz4VihifZ9NwjwBEK46qmWoY',
  //     refreshToken: '',
  //   );
  //
  //   return TeacherRequestApiKhanh().getMyRequests();
  // }

  /* Reload requests from server. */
  Future<void> _reload() async {
    final newFuture = TeacherRequestApiKhanh().getMyRequests();

    setState(() {
      _future = newFuture;
    });

    await newFuture;
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

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'cancelled':
        return Icons.remove_circle_outline;
      default:
        return Icons.schedule_outlined;
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

  /* Navigate back to available subject screen. */
  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/teacher-request/available-subjects');
  }

  /* Show request detail bottom sheet. */
  void _showRequestDetail(TeacherRequestModelKhanh request) {
    final bool hasCertificate = request.certificationUrl != null &&
        request.certificationUrl!.trim().isNotEmpty;

    final bool hasAdminNote =
        request.adminNote != null && request.adminNote!.trim().isNotEmpty;

    final bool hasReviewer =
        request.reviewerName != null && request.reviewerName!.trim().isNotEmpty;

    final Color statusColor = _statusColor(request.status);
    final Color statusBackground = _statusBackground(request.status);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
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
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xffffeee8),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.assignment_outlined,
                                color: primaryColor,
                                size: 25,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Request #${request.teacherRequestId}',
                                    style: const TextStyle(
                                      color: darkColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Teaching registration details',
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 13,
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
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: statusBackground,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _statusIcon(request.status),
                                color: statusColor,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Current status',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 13,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                request.status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        const _DetailSectionTitleKhanh(
                          icon: Icons.menu_book_outlined,
                          title: 'Request information',
                        ),
                        const SizedBox(height: 12),
                        _DetailCardKhanh(
                          children: [
                            _DetailRowKhanh(
                              label: 'Subject',
                              value: request.subjectName,
                            ),
                            const Divider(height: 24),
                            _DetailRowKhanh(
                              label: 'Reason',
                              value: request.reason?.trim().isNotEmpty == true
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
                        if (hasReviewer || request.reviewedAt != null) ...[
                          const SizedBox(height: 22),
                          const _DetailSectionTitleKhanh(
                            icon: Icons.fact_check_outlined,
                            title: 'Review information',
                          ),
                          const SizedBox(height: 12),
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
                                  value: _formatDate(request.reviewedAt),
                                ),
                            ],
                          ),
                        ],
                        if (hasAdminNote) ...[
                          const SizedBox(height: 22),
                          const _DetailSectionTitleKhanh(
                            icon: Icons.info_outline,
                            title: 'Admin note',
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xfffff8f4),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(0xffffd7c7),
                              ),
                            ),
                            child: Text(
                              request.adminNote!,
                              style: const TextStyle(
                                color: darkColor,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                        if (hasCertificate) ...[
                          const SizedBox(height: 22),
                          const _DetailSectionTitleKhanh(
                            icon: Icons.attach_file,
                            title: 'Certification',
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xfff6f7fb),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(0xffe6e9ef),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffffeee8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.description_outlined,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Certification attached',
                                        style: TextStyle(
                                          color: darkColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        'Copy the certification path',
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 12,
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
                                        text: request.certificationUrl!,
                                      ),
                                    );

                                    if (!mounted) {
                                      return;
                                    }

                                    ScaffoldMessenger.of(this.context)
                                        .showSnackBar(
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
                ],
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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 900,
            ),
            child: Column(
              children: [
                _HeaderKhanh(
                  onBack: _goBack,
                  onRefresh: _reload,
                ),
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

                      final List<TeacherRequestModelKhanh> requests =
                          snapshot.data ?? [];

                      if (requests.isEmpty) {
                        return _EmptyStateKhanh(
                          onRefresh: _reload,
                        );
                      }

                      return RefreshIndicator(
                        color: primaryColor,
                        onRefresh: _reload,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            16,
                            16,
                            70,
                          ),
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final request = requests[index];

                            return _RequestCardKhanh(
                              request: request,
                              statusColor: _statusColor(request.status),
                              statusBackground:
                              _statusBackground(request.status),
                              createdAt: _formatDate(request.createdAt),
                              onViewDetails: () {
                                _showRequestDetail(request);
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
      ),
    );
  }
}

class _HeaderKhanh extends StatelessWidget {
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;

  const _HeaderKhanh({
    required this.onBack,
    required this.onRefresh,
  });

  static const Color darkColor = Color(0xff183153);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 8, 14, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 5),
            color: Color(0x10000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back to available subjects',
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: darkColor,
                  size: 20,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Refresh requests',
                onPressed: onRefresh,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: darkColor,
                  size: 25,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'My Teacher Requests',
              style: TextStyle(
                color: darkColor,
                fontSize: 25,
                height: 1.15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'View and track the status of your teaching requests.',
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCardKhanh extends StatelessWidget {
  final TeacherRequestModelKhanh request;
  final Color statusColor;
  final Color statusBackground;
  final String createdAt;
  final VoidCallback onViewDetails;

  const _RequestCardKhanh({
    required this.request,
    required this.statusColor,
    required this.statusBackground,
    required this.createdAt,
    required this.onViewDetails,
  });

  static const Color primaryColor = Color(0xfff15a22);
  static const Color darkColor = Color(0xff183153);

  @override
  Widget build(BuildContext context) {
    final bool hasAdminNote =
        request.adminNote != null && request.adminNote!.trim().isNotEmpty;

    final bool hasCertificate = request.certificationUrl != null &&
        request.certificationUrl!.trim().isNotEmpty;

    final bool hasReviewer =
        request.reviewerName != null && request.reviewerName!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xffe8ebf1),
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            offset: Offset(0, 5),
            color: Color(0x0d000000),
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
          const SizedBox(height: 14),
          Text(
            request.subjectName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: darkColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
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
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 9,
            children: [
              _CompactInfoKhanh(
                icon: Icons.calendar_today_outlined,
                text: 'Created: $createdAt',
              ),
              if (hasCertificate)
                const _CompactInfoKhanh(
                  icon: Icons.attach_file,
                  text: 'Certification attached',
                ),
              if (hasReviewer)
                _CompactInfoKhanh(
                  icon: Icons.person_outline,
                  text: 'Reviewed by ${request.reviewerName}',
                ),
            ],
          ),
          if (hasAdminNote) ...[
            const SizedBox(height: 13),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xfffff8f4),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: const Color(0xffffded2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.adminNote!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkColor,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onViewDetails,
              icon: const Icon(
                Icons.visibility_outlined,
                size: 18,
              ),
              label: const Text(
                'View Details',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffffeee8),
                foregroundColor: primaryColor,
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
        ],
      ),
    );
  }
}

class _CompactInfoKhanh extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CompactInfoKhanh({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: Colors.blueGrey,
        ),
        const SizedBox(width: 5),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 240,
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailSectionTitleKhanh extends StatelessWidget {
  final IconData icon;
  final String title;

  const _DetailSectionTitleKhanh({
    required this.icon,
    required this.title,
  });

  static const Color primaryColor = Color(0xfff15a22);
  static const Color darkColor = Color(0xff183153);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: primaryColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: darkColor,
            fontSize: 16,
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xfff8f9fc),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xffe8ebf1),
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

  static const Color darkColor = Color(0xff183153);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.blueGrey,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: darkColor,
            fontSize: 14,
            height: 1.4,
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
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
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
  static const Color darkColor = Color(0xff183153);

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
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xffffeee8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                color: primaryColor,
                size: 42,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'No teacher requests yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkColor,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your teaching registration requests will appear here after submission.',
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
  final Future<void> Function() onRetry;

  const _ErrorStateKhanh({
    required this.message,
    required this.onRetry,
  });

  static const Color primaryColor = Color(0xfff15a22);
  static const Color darkColor = Color(0xff183153);

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
              size: 52,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load requests',
              style: TextStyle(
                color: darkColor,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
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