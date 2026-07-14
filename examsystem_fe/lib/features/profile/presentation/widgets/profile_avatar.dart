import 'package:flutter/material.dart';
import '../../../../core/network/dio_client.dart';

/// Avatar circle pixel-perfect theo HTML:
/// - 80x80 rounded full
/// - border 3px white
/// - shadow
/// - Camera icon overlay bottom-right (24x24, white bg, camera icon fill)
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onCameraTap;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      height: 86,
      child: Stack(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildImage(),
            ),
          ),
          // Camera overlay
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onCameraTap,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE2BFB4),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 14,
                  color: Color(0xFFF15A22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty && imageUrl != 'default.png') {
      String finalUrl = imageUrl!;
      if (finalUrl.startsWith('/uploads')) {
        final baseUrl = DioClient.instance.options.baseUrl.replaceAll('/api', '');
        finalUrl = '$baseUrl$finalUrl';
      }

      // Thêm cache-busting để avatar thay đổi ngay lập tức
      final cacheBuster = DateTime.now().millisecondsSinceEpoch;
      finalUrl = finalUrl.contains('?') 
          ? '$finalUrl&v=$cacheBuster' 
          : '$finalUrl?v=$cacheBuster';

      return Image.network(
        finalUrl,
        width: 74,
        height: 74,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: const Color(0xFFF15A22),
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 74,
      height: 74,
      color: const Color(0xFFFFF3EE),
      child: const Icon(
        Icons.person,
        size: 40,
        color: Color(0xFFF15A22),
      ),
    );
  }
}
