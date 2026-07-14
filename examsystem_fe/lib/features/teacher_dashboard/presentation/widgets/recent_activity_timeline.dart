import 'package:flutter/material.dart';

/// Timeline hoạt động gần đây — mock data tĩnh.
///
/// Không gọi API — dùng dữ liệu cứng theo HTML mockup.
class RecentActivityTimeline extends StatelessWidget {
  const RecentActivityTimeline({super.key});

  static const _mockActivities = [
    _Activity(name: 'Van A', action: 'submitted Midterm', timeAgo: '2h ago'),
    _Activity(name: 'Binh Nguyen', action: 'commented on Q4', timeAgo: '4h ago'),
    _Activity(name: 'Minh Huy', action: 'requested retake', timeAgo: '6h ago'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              color: Color(0xFF1D3557),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Timeline container
          Stack(
            children: [
              // Đường timeline đứng
              Positioned(
                left: 7,
                top: 8,
                bottom: 8,
                child: Container(
                  width: 2,
                  color: const Color(0xFFF15A22).withValues(alpha: 0.15),
                ),
              ),

              // Danh sách entries
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Column(
                  children: _mockActivities.asMap().entries.map((entry) {
                    return _ActivityEntry(
                      activity: entry.value,
                      isLast: entry.key == _mockActivities.length - 1,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Activity {
  final String name;
  final String action;
  final String timeAgo;
  const _Activity({
    required this.name,
    required this.action,
    required this.timeAgo,
  });
}

class _ActivityEntry extends StatelessWidget {
  final _Activity activity;
  final bool isLast;

  const _ActivityEntry({required this.activity, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
      child: Row(
        children: [
          // Chấm tròn cam (positioned tương đối với timeline line)
          Transform.translate(
            offset: const Offset(-30.5, 0),
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFFF15A22),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),

          // Avatar placeholder
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFFE5EEFF),
            child: Text(
              activity.name[0],
              style: const TextStyle(
                color: Color(0xFF1D3557),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Color(0xFF1D3557),
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: activity.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' ${activity.action}'),
                    ],
                  ),
                ),
                Text(
                  activity.timeAgo,
                  style: const TextStyle(
                    color: Color(0xFF485F84),
                    fontSize: 11,
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
