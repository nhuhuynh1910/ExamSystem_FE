import 'package:flutter/material.dart';

import '../models/ranking_model_khanh.dart';

class PodiumWidgetKhanh extends StatelessWidget {
  final List<RankingItemModelKhanh> items;

  const PodiumWidgetKhanh({
    super.key,
    required this.items,
  });

  static const Color _primaryColor = Color(0xFFFF5A2A);
  static const Color _secondColor = Color(0xFF99A2B1);
  static const Color _thirdColor = Color(0xFFE07A00);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final RankingItemModelKhanh? first =
    items.isNotEmpty ? items[0] : null;
    final RankingItemModelKhanh? second =
    items.length > 1 ? items[1] : null;
    final RankingItemModelKhanh? third =
    items.length > 2 ? items[2] : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _PodiumPersonKhanh(
              item: second,
              position: 2,
              podiumHeight: 55,
              podiumColor: _secondColor,
              avatarSize: 48,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _PodiumPersonKhanh(
              item: first,
              position: 1,
              podiumHeight: 78,
              podiumColor: _primaryColor,
              avatarSize: 58,
              isWinner: true,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _PodiumPersonKhanh(
              item: third,
              position: 3,
              podiumHeight: 48,
              podiumColor: _thirdColor,
              avatarSize: 46,
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumPersonKhanh extends StatelessWidget {
  final RankingItemModelKhanh? item;
  final int position;
  final double podiumHeight;
  final Color podiumColor;
  final double avatarSize;
  final bool isWinner;

  const _PodiumPersonKhanh({
    required this.item,
    required this.position,
    required this.podiumHeight,
    required this.podiumColor,
    required this.avatarSize,
    this.isWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    if (item == null) {
      return SizedBox(
        height: 180,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: podiumHeight,
            decoration: BoxDecoration(
              color: podiumColor.withValues(alpha: 0.25),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isWinner)
          const Padding(
            padding: EdgeInsets.only(bottom: 3),
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 24,
              color: Color(0xFFFF5A2A),
            ),
          ),
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: podiumColor.withValues(alpha: 0.14),
            border: Border.all(
              color: podiumColor,
              width: isWinner ? 3 : 2,
            ),
          ),
          child: Center(
            child: Text(
              _getInitials(item!.studentName),
              style: TextStyle(
                color: podiumColor,
                fontSize: isWinner ? 17 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item!.studentName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF183153),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: podiumColor.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_formatScore(item!.score)} pts',
            style: TextStyle(
              color: podiumColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: podiumHeight,
          decoration: BoxDecoration(
            color: podiumColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                color: podiumColor.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            _positionText(position),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
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

  String _positionText(int value) {
    switch (value) {
      case 1:
        return '1st';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
      default:
        return '$value';
    }
  }
}