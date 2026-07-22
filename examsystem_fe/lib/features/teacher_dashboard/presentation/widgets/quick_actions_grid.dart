import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../exam/screens/create_exam_screen.dart';

/// Grid 4 nút Quick Actions.
///
/// Mỗi nút hiện SnackBar "Coming soon!" khi nhấn.
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
          icon: Icons.add_circle,
          label: 'New\nQuestion',
          onTap: () => context.push('/questions')),
      _QuickAction(
          icon: Icons.assignment_add,
          label: 'New\nExam',
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateExamScreen()))),
      _QuickAction(
          icon: Icons.analytics,
          label: 'Exams',
          onTap: () => context.push('/exams')),
      _QuickAction(
          icon: Icons.groups,
          label: 'Students',
          onTap: () => context.push('/student/courses/catalog')),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: actions.map((action) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _QuickActionButton(action: action),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});
}

class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF15A22),
                shape: BoxShape.circle,
              ),
              child: Icon(
                action.icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1D3557),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
