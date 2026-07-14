import 'package:flutter/material.dart';

/// Gradient banner header pixel-perfect theo HTML:
/// - gradient: linear-gradient(135deg, #F15A22, #FF8C42)
/// - height: 180
/// - Title "Profile" centered
/// - Settings icon button top-right
///
/// Avatar nằm ngoài widget này (overlapping) — xử lý bằng Stack ở ProfileScreen.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF15A22),
            Color(0xFFFF8C42),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Spacer to balance the settings button for centering title
              const SizedBox(width: 40),
              // Title
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              // Settings button
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // TODO: Navigate to settings
                    },
                    borderRadius: BorderRadius.circular(20),
                    splashColor: Colors.white24,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
