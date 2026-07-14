import 'package:flutter/material.dart';

/// Filter tabs: All, Draft, Published, Closed.
///
/// Active tab = nền FPT Orange + chữ trắng.
/// Inactive tab = nền xám nhạt + viền.
class ExamFilterTabs extends StatelessWidget {
  /// null = "All".
  final String? activeFilter;

  /// Callback khi chọn tab. Truyền null = "All".
  final ValueChanged<String?> onFilterChanged;

  const ExamFilterTabs({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  static const _filters = [
    (label: 'All', value: null),
    (label: 'Draft', value: 'Draft'),
    (label: 'Published', value: 'Published'),
    (label: 'Closed', value: 'Closed'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isActive = activeFilter == filter.value;

          return GestureDetector(
            onTap: () => onFilterChanged(filter.value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFF15A22)
                    : const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(20),
                border: isActive
                    ? null
                    : Border.all(color: const Color(0xFFE2BFB4)),
              ),
              child: Center(
                child: Text(
                  filter.label,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF485F84),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
