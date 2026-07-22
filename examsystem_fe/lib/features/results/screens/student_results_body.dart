import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/skeleton_loader.dart';

import '../bloc/results_bloc.dart';
import '../bloc/results_event.dart';
import '../bloc/results_state.dart';
import '../widgets/result_card_widget.dart';

/// StudentResultsBody — Màn hình kết quả thi dành cho Student kết nối API thực tế.
///
/// Được nhúng vào IndexedStack trong StudentDashboardScreen (index = 2).
class StudentResultsBody extends StatelessWidget {
  const StudentResultsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ResultsBloc()..add(const LoadStudentResultsEvent()),
      child: const _StudentResultsView(),
    );
  }
}

class _StudentResultsView extends StatelessWidget {
  const _StudentResultsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResultsBloc, ResultsState>(
      builder: (context, state) {
        if (state is ResultsLoading) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: SkeletonListLoader(count: 4, cardHeight: 100),
          );
        }

        if (state is ResultsError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 56, color: Colors.red.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load results: ${state.message}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context
                        .read<ResultsBloc>()
                        .add(const LoadStudentResultsEvent()),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF15A22),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is ResultsLoaded) {
          final results = state.results;

          if (results.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.leaderboard_outlined,
                        size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text(
                      'No exam results yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D3557),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your exam results will automatically appear here after you complete an exam.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<ResultsBloc>()
                  .add(const LoadStudentResultsEvent());
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: results.length,
              itemBuilder: (context, index) {
                return ResultCardWidget(result: results[index]);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
