import 'package:flutter/material.dart';

/// Sign Out Card pixel-perfect theo HTML:
/// - Card rounded-xl, shadow, border
/// - Logout icon (red circle bg) + "Sign Out" text (red)
/// - Active effect: red-50 background
class ProfileSignOutCard extends StatelessWidget {
  final VoidCallback? onSignOut;

  const ProfileSignOutCard({
    super.key,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSignOut,
          splashColor: Colors.red.shade50,
          highlightColor: Colors.red.shade50,
          child: SizedBox(
            height: 52,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Logout icon circle
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.logout,
                      size: 18,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Sign Out text
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
