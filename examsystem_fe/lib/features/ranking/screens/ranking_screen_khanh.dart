import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/ranking_cubit_khanh.dart';
import '../bloc/ranking_state_khanh.dart';
import '../models/ranking_model_khanh.dart';
import '../widgets/podium_widget_khanh.dart';
import '../widgets/ranking_item_card_khanh.dart';

class RankingScreenKhanh extends StatelessWidget {
  final int examId;
  final int? currentStudentId;

  const RankingScreenKhanh({
    super.key,
    required this.examId,
    this.currentStudentId,
  });

  static const Color _primaryColor = Color(0xFFFF5A2A);
  static const Color _backgroundColor = Color(0xFFF6F7FB);
  static const Color _darkTextColor = Color(0xFF183153);
  static const Color _secondaryTextColor = Color(0xFF7A8494);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        return RankingCubitKhanh()
          ..loadRanking(
            examId: examId,
            top: 5,
          );
      },
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: BlocBuilder<RankingCubitKhanh, RankingStateKhanh>(
          builder: (context, state) {
            if (state is RankingInitialKhanh ||
                state is RankingLoadingKhanh) {
              return _buildLoading();
            }

            if (state is RankingErrorKhanh) {
              return _buildError(
                context: context,
                message: state.message,
              );
            }

            if (state is RankingLoadedKhanh) {
              return _buildRankingContent(
                context: context,
                ranking: state.ranking,
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const SafeArea(
      child: Column(
        children: [
          _RankingHeaderKhanh(),
          Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: _primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError({
    required BuildContext context,
    required String message,
  }) {
    final cleanMessage = message.replaceFirst('Exception: ', '');

    return SafeArea(
      child: Column(
        children: [
          const _RankingHeaderKhanh(),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: _primaryColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        color: _primaryColor,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Unable to load ranking',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _darkTextColor,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cleanMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _secondaryTextColor,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<RankingCubitKhanh>()
                            .loadRanking(
                          examId: examId,
                          top: 5,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(
                        Icons.refresh_rounded,
                        size: 18,
                      ),
                      label: const Text(
                        'Try again',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingContent({
    required BuildContext context,
    required RankingModelKhanh ranking,
  }) {
    if (ranking.items.isEmpty) {
      return _buildEmpty(context);
    }

    final sortedItems = List<RankingItemModelKhanh>.from(
      ranking.items,
    )..sort((a, b) => a.rank.compareTo(b.rank));

    final topThree = sortedItems
        .where((item) => item.rank <= 3)
        .toList();

    final remainingItems = sortedItems
        .where((item) => item.rank > 3)
        .toList();

    return SafeArea(
      child: Column(
        children: [
          _RankingHeaderKhanh(
            examName: ranking.examName,
          ),
          Expanded(
            child: RefreshIndicator(
              color: _primaryColor,
              onRefresh: () {
                return context
                    .read<RankingCubitKhanh>()
                    .refresh(
                  examId: examId,
                  top: 5,
                );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: 12,
                  bottom: 24,
                ),
                children: [
                  PodiumWidgetKhanh(
                    items: topThree,
                  ),
                  const SizedBox(height: 14),
                  if (remainingItems.isNotEmpty)
                    ...remainingItems.map(
                          (item) {
                        final isCurrentUser =
                            currentStudentId != null &&
                                item.studentId == currentStudentId;

                        return RankingItemCardKhanh(
                          item: item,
                          isCurrentUser: isCurrentUser,
                        );
                      },
                    ),
                  if (remainingItems.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 22,
                      ),
                      child: Center(
                        child: Text(
                          'Only the top three students are available.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const _RankingHeaderKhanh(),
          Expanded(
            child: RefreshIndicator(
              color: _primaryColor,
              onRefresh: () {
                return context
                    .read<RankingCubitKhanh>()
                    .refresh(
                  examId: examId,
                  top: 5,
                );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                ),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                  ),
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: _primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events_outlined,
                      color: _primaryColor,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No ranking available',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _darkTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The leaderboard will appear after students submit the exam.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _secondaryTextColor,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingHeaderKhanh extends StatelessWidget {
  final String? examName;

  const _RankingHeaderKhanh({
    this.examName,
  });

  static const Color _primaryColor = Color(0xFFFF5A2A);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        12,
        14,
        16,
        14,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF835D),
            _primaryColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.emoji_events_rounded,
            color: Color(0xFFFFE15D),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ranking',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (examName != null && examName!.trim().isNotEmpty)
                  Text(
                    examName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontSize: 10,
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