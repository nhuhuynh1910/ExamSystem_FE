import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/teacher_request_cubit_khanh.dart';
import '../data/teacher_request_api_khanh.dart';
import '../domain/teacher_request_repository_khanh.dart';
import '../models/teacher_request_model_khanh.dart';

class MyTeacherRequestsScreenKhanh extends StatefulWidget {
  const MyTeacherRequestsScreenKhanh({super.key});

  @override
  State<MyTeacherRequestsScreenKhanh> createState() =>
      _MyTeacherRequestsScreenKhanhState();
}

class _MyTeacherRequestsScreenKhanhState
    extends State<MyTeacherRequestsScreenKhanh> {
  final TextEditingController _searchController = TextEditingController();

  static const Color primaryColor = Color(0xfff45a24);
  static const Color backgroundColor = Color(0xfff7f8fc);
  static const Color darkColor = Color(0xff183153);

  @override
  void initState() {
    super.initState();
  }

  List<TeacherRequestModelKhanh> _filterRequests(
    List<TeacherRequestModelKhanh> requests,
  ) {
    final keyword = _searchController.text.trim().toLowerCase();

    if (keyword.isEmpty) {
      return requests;
    }

    return requests.where((request) {
      final id = request.teacherRequestId.toString();
      final subject = request.subjectName.toLowerCase();
      final reason = (request.reason ?? '').toLowerCase();
      final status = request.status.toLowerCase();

      return id.contains(keyword) ||
          subject.contains(keyword) ||
          reason.contains(keyword) ||
          status.contains(keyword);
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xff27a94f);
      case 'rejected':
        return const Color(0xffe64b4b);
      case 'cancelled':
        return Colors.grey;
      default:
        return const Color(0xffff8a00);
    }
  }

  Color _statusBackground(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xffe6f8eb);
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
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/exams');
    }
  }

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
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
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
                                    Icons.assignment_outlined,
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
                                        'Request #${request.teacherRequestId}',
                                        style: const TextStyle(
                                          color: darkColor,
                                          fontSize: 19,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      const Text(
                                        'Teaching registration details',
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
                                  onPressed: () => Navigator.pop(bottomSheetContext),
                                  icon: const Icon(Icons.close_rounded),
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
                                      request.reason?.trim().isNotEmpty == true
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
                                  if (hasReviewer && request.reviewedAt != null)
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
                                  color: const Color(0xfffff8f4),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xffffd7c7),
                                  ),
                                ),
                                child: Text(
                                  request.adminNote!,
                                  style: const TextStyle(
                                    color: darkColor,
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
                                        borderRadius: BorderRadius.circular(11),
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
                                              color: darkColor,
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
                                              text: request.certificationUrl!),
                                        );
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Certification path copied.'),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
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
                ),
              ),
            );
          },
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
      create: (_) => TeacherRequestCubitKhanh(
        TeacherRequestRepositoryKhanh(
          TeacherRequestApiKhanh(),
        ),
      )..loadMyRequests(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          foregroundColor: darkColor,
          leading: IconButton(
            tooltip: 'Back',
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 21),
          ),
          titleSpacing: 0,
          title: const Text(
            'My Teacher Requests',
            style: TextStyle(
              color: darkColor,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            Builder(builder: (context) {
              return IconButton(
                tooltip: 'Refresh requests',
                onPressed: () =>
                    context.read<TeacherRequestCubitKhanh>().loadMyRequests(),
                icon: const Icon(Icons.refresh_rounded, color: primaryColor),
              );
            }),
            const SizedBox(width: 5),
          ],
        ),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isDesktop = constraints.maxWidth >= 900;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 0),
                child: BlocBuilder<TeacherRequestCubitKhanh,
                    TeacherRequestStateKhanh>(
                  builder: (context, state) {
                    if (state.isLoading && state.requests.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      );
                    }

                    if (state.error != null && state.requests.isEmpty) {
                      return _ErrorStateKhanh(
                        message: state.error!,
                        onRetry: () => context
                            .read<TeacherRequestCubitKhanh>()
                            .loadMyRequests(),
                      );
                    }

                    final allRequests = state.requests;
                    final filteredRequests = _filterRequests(allRequests);

                    return Column(
                      children: [
                        _PageHeaderKhanh(
                          searchController: _searchController,
                          onSearchChanged: () => setState(() {}),
                        ),
                        Expanded(
                          child: allRequests.isEmpty
                              ? _EmptyStateKhanh(
                                  isSearching: false,
                                  onRefresh: () async => context
                                      .read<TeacherRequestCubitKhanh>()
                                      .loadMyRequests(),
                                )
                              : filteredRequests.isEmpty
                                  ? _EmptyStateKhanh(
                                      isSearching: true,
                                      onRefresh: () async => context
                                          .read<TeacherRequestCubitKhanh>()
                                          .loadMyRequests(),
                                    )
                                  : RefreshIndicator(
                                      color: primaryColor,
                                      onRefresh: () async => context
                                          .read<TeacherRequestCubitKhanh>()
                                          .loadMyRequests(),
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          final int columnCount = constraints
                                                      .maxWidth >=
                                                  1200
                                              ? 3
                                              : constraints.maxWidth >= 800
                                                  ? 2
                                                  : 1;

                                          if (columnCount == 1) {
                                            return ListView.builder(
                                              physics:
                                                  const AlwaysScrollableScrollPhysics(),
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      14, 8, 14, 90),
                                              itemCount:
                                                  filteredRequests.length,
                                              itemBuilder: (context, index) {
                                                final request =
                                                    filteredRequests[index];
                                                return _RequestCardKhanh(
                                                  request: request,
                                                  statusColor: _statusColor(
                                                      request.status),
                                                  statusBackground:
                                                      _statusBackground(
                                                          request.status),
                                                  createdAt: _formatDate(
                                                      request.createdAt),
                                                  onViewDetails: () =>
                                                      _showRequestDetail(
                                                          request),
                                                );
                                              },
                                            );
                                          }

                                          return GridView.builder(
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            padding: const EdgeInsets.fromLTRB(
                                                14, 8, 14, 90),
                                            itemCount: filteredRequests.length,
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: columnCount,
                                              crossAxisSpacing: 14,
                                              mainAxisSpacing: 14,
                                              childAspectRatio: 1.45,
                                            ),
                                            itemBuilder: (context, index) {
                                              final request =
                                                  filteredRequests[index];
                                              return _RequestCardKhanh(
                                                request: request,
                                                statusColor: _statusColor(
                                                    request.status),
                                                statusBackground:
                                                    _statusBackground(
                                                        request.status),
                                                createdAt: _formatDate(
                                                    request.createdAt),
                                                onViewDetails: () =>
                                                    _showRequestDetail(request),
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
      ),
    );
  }
}

class _PageHeaderKhanh extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onSearchChanged;

  const _PageHeaderKhanh({
    required this.searchController,
    required this.onSearchChanged,
  });

  static const Color darkColor = Color(0xff183153);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 17, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Teacher Requests',
            style: TextStyle(
              color: darkColor,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Track your teaching registration requests.',
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by ID or subject...',
              prefixIcon:
                  const Icon(Icons.search_rounded, color: Colors.blueGrey),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged();
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: const Color(0xfff4f6fa),
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
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

  static const Color primaryColor = Color(0xfff45a24);
  static const Color darkColor = Color(0xff183153);

  @override
  Widget build(BuildContext context) {
    final bool hasCertificate = request.certificationUrl != null &&
        request.certificationUrl!.trim().isNotEmpty;
    final bool hasAdminNote =
        request.adminNote != null && request.adminNote!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffffddd1)),
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
              Text(
                'REQ-${request.teacherRequestId.toString().padLeft(4, '0')}',
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              _StatusBadgeKhanh(
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
              color: darkColor,
              fontSize: 15,
              height: 1.3,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            request.reason?.trim().isNotEmpty == true
                ? request.reason!
                : 'No reason provided',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 11,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 11),
          _SmallInfoKhanh(
            icon: Icons.calendar_today_outlined,
            text: 'Created on: $createdAt',
          ),
          if (hasCertificate) ...[
            const SizedBox(height: 7),
            const _SmallInfoKhanh(
              icon: Icons.attach_file_rounded,
              text: 'Certification attached',
            ),
          ],
          if (hasAdminNote) ...[
            const SizedBox(height: 9),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xfffff7f2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                request.adminNote!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: darkColor,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SmallInfoKhanh extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SmallInfoKhanh({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.blueGrey),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.blueGrey, fontSize: 10),
          ),
        ),
      ],
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
  static const Color darkColor = Color(0xff183153);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 19),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            color: darkColor,
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

  const _DetailCardKhanh({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfff7f8fc),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffe7eaf0)),
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

  const _DetailRowKhanh({required this.label, required this.value});

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
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: darkColor,
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
  final Future<void> Function() onRefresh;

  const _EmptyStateKhanh({required this.isSearching, required this.onRefresh});

  static const Color primaryColor = Color(0xfff45a24);
  static const Color darkColor = Color(0xff183153);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: primaryColor,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 75),
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
                isSearching ? Icons.search_off_rounded : Icons.assignment_outlined,
                color: primaryColor,
                size: 39,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isSearching ? 'No matching requests' : 'No teacher requests yet',
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
                ? 'Try searching with another request ID or subject.'
                : 'Your teaching registration requests will appear here after submission.',
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

  const _ErrorStateKhanh({required this.message, required this.onRetry});

  static const Color primaryColor = Color(0xfff45a24);
  static const Color darkColor = Color(0xff183153);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 14),
            const Text(
              'Unable to load requests',
              style: TextStyle(
                color: darkColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
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
