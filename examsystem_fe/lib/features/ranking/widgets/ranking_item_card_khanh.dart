import 'package:flutter/material.dart';

import '../models/ranking_model_khanh.dart';

class RankingItemCardKhanh extends StatelessWidget {
  final RankingItemModelKhanh item;
  final bool isCurrentUser;

  const RankingItemCardKhanh({
    super.key,
    required this.item,
    this.isCurrentUser = false,
  });

  static const Color _primaryColor = Color(0xFFFF5A2A);
  static const Color _darkTextColor = Color(0xFF183153);
  static const Color _secondaryTextColor = Color(0xFF7A8494);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? const Color(0xFFFFF1EC)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: isCurrentUser
                ? _primaryColor
                : Colors.transparent,
            width: 3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${item.rank}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isCurrentUser
                    ? _primaryColor
                    : _secondaryTextColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildAvatar(),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStudentInformation(),
          ),
          const SizedBox(width: 8),
          _buildResultInformation(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCurrentUser
            ? _primaryColor.withValues(alpha: 0.12)
            : const Color(0xFFF1F3F6),
      ),
      alignment: Alignment.center,
      child: Text(
        _getInitials(item.studentName),
        style: TextStyle(
          color: isCurrentUser
              ? _primaryColor
              : _darkTextColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStudentInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                item.studentName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _darkTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isCurrentUser) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'YOU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Text(
          item.username.isNotEmpty
              ? '@${item.username}'
              : 'Student',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _secondaryTextColor,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildResultInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? _primaryColor.withValues(alpha: 0.13)
                : const Color(0xFFF4F5F7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_formatScore(item.score)} pts',
            style: TextStyle(
              color: isCurrentUser
                  ? _primaryColor
                  : _darkTextColor,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 10,
              color: _secondaryTextColor,
            ),
            const SizedBox(width: 3),
            Text(
              item.durationText,
              style: TextStyle(
                color: isCurrentUser
                    ? _primaryColor
                    : _secondaryTextColor,
                fontSize: 8,
                fontWeight: isCurrentUser
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatScore(double score) {
    if (score == score.roundToDouble()) {
      return score.toInt().toString();
    }

    return score.toStringAsFixed(1);
  }
}