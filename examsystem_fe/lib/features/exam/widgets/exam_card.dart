import 'package:flutter/material.dart';
import '../../../core/network/api_constants.dart';
import '../models/exam_model.dart';
import 'status_chip.dart';

class ExamCard extends StatelessWidget {
  final ExamModel exam;
  final int? currentUserId;
  final String? userRole;
  final VoidCallback onTap;
  final Function(String) onAction;

  const ExamCard({
    super.key,
    required this.exam,
    this.currentUserId,
    this.userRole,
    required this.onTap,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final bool canManage = userRole == 'Admin' || currentUserId == exam.teacherId;
    final String? imageUrl = exam.examImageUrl != null && exam.examImageUrl!.isNotEmpty
        ? (exam.examImageUrl!.startsWith('http') ? exam.examImageUrl : "${ApiConstants.baseUrl.replaceAll('/api', '')}${exam.examImageUrl}")
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon/Image Section
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.assignment_outlined, color: Color(0xFFF97316)),
                            ),
                          )
                        : const Icon(Icons.assignment_outlined, color: Color(0xFFF97316)),
                  ),
                  const SizedBox(width: 14),
                  // Info Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.examName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (exam.subjectName ?? 'Unknown Subject').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF97316),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(status: exam.status),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),
              Row(
                children: [
                  _buildInfoItem(Icons.help_outline_rounded, '${exam.questionCount ?? 0} questions'),
                  const SizedBox(width: 16),
                  _buildInfoItem(Icons.people_outline_rounded, '${exam.attemptCount ?? 0} attempts'),
                  const Spacer(),
                  if (canManage)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz, color: Colors.grey, size: 22),
                      onSelected: onAction,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 150),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      itemBuilder: (context) => [
                        if (exam.status == 'Draft') ...[
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 10), Text('Edit Exam')]),
                          ),
                          const PopupMenuItem(
                            value: 'publish',
                            child: Row(children: [Icon(Icons.publish_outlined, size: 18), SizedBox(width: 10), Text('Publish Now')]),
                          ),
                        ],
                        if (exam.status == 'Published')
                          const PopupMenuItem(
                            value: 'close',
                            child: Row(children: [Icon(Icons.lock_outline, size: 18), SizedBox(width: 10), Text('Close Access')]),
                          ),
                        if (exam.status == 'Closed')
                          const PopupMenuItem(
                            value: 'restore',
                            child: Row(children: [Icon(Icons.refresh_rounded, size: 18), SizedBox(width: 10), Text('Re-open (Draft)')]),
                          ),
                        if (exam.status == 'Deleted')
                          const PopupMenuItem(
                            value: 'restore',
                            child: Row(children: [Icon(Icons.restore, size: 18), SizedBox(width: 10), Text('Restore Exam')]),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 10), Text('Delete', style: TextStyle(color: Colors.red))]),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
