import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../block/exam_list_cubit.dart';
import '../block/exam_list_state.dart';
import '../models/exam_model.dart';

/// Màn hình danh sách đề thi - route /exams
class ExamListScreen extends StatelessWidget {
  const ExamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text(
          'Danh sách đề thi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
      ),
      body: BlocBuilder<ExamListCubit, ExamListState>(
        builder: (context, state) => switch (state) {
          ExamListInitial()  => const SizedBox.shrink(),
          ExamListLoading()  => const Center(child: CircularProgressIndicator(color: Color(0xFFE94560))),
          ExamListError(:final message) => _ErrorView(
              message: message,
              onRetry: () => context.read<ExamListCubit>().loadExams(),
            ),
          ExamListLoaded(:final paginated) => paginated.items.isEmpty
              ? const _EmptyView()
              : _ExamGrid(exams: paginated.items),
        },
      ),
    );
  }
}

// ── Grid ──
class _ExamGrid extends StatelessWidget {
  final List<ExamModel> exams;
  const _ExamGrid({required this.exams});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: exams.length,
      itemBuilder: (context, index) => _ExamCard(exam: exams[index]),
    );
  }
}

// ── Card ──
class _ExamCard extends StatelessWidget {
  final ExamModel exam;
  const _ExamCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/exams/${exam.examId}'),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF16213E), Color(0xFF1A1A2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(20)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh hoặc fallback
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: exam.examImageUrl != null
                  ? Image.network(
                      exam.examImageUrl!,
                      height: 80,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _FallbackImage(exam: exam),
                    )
                  : _FallbackImage(exam: exam),
            ),
            const SizedBox(height: 10),
            Text(
              exam.examName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              exam.subjectName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white.withAlpha(153), fontSize: 11),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 12, color: Color(0xFF00B4D8)),
                const SizedBox(width: 3),
                Text(
                  '${exam.durationMinutes} phút',
                  style: const TextStyle(color: Color(0xFF00B4D8), fontSize: 11),
                ),
                const Spacer(),
                if (exam.isPrivate)
                  const Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFFE94560)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Fallback image ──
class _FallbackImage extends StatelessWidget {
  final ExamModel exam;
  const _FallbackImage({required this.exam});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF533483), Color(0xFFE94560)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          exam.examName.isNotEmpty ? exam.examName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ── Empty ──
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.white.withAlpha(80)),
          const SizedBox(height: 12),
          Text('Chưa có đề thi nào.', style: TextStyle(color: Colors.white.withAlpha(120))),
        ],
      ),
    );
  }
}

// ── Error ──
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: Color(0xFFE94560)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                foregroundColor: Colors.white,
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
