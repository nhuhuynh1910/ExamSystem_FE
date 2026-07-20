import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../block/start_exam_cubit.dart';
import '../block/start_exam_state.dart';
import '../block/exam_detail_cubit.dart';
import '../block/exam_detail_state.dart';
import '../models/exam_model.dart';
import 'exam_taking_screen.dart';

class ExamDetailScreen extends StatelessWidget {
  final int examId;
  const ExamDetailScreen({super.key, required this.examId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExamDetailCubit, ExamDetailState>(
      builder: (context, state) => switch (state) {
        ExamDetailInitial() => const _LoadingScaffold(),
        ExamDetailLoading() => const _LoadingScaffold(),
        ExamDetailError(:final message) => _ErrorScaffold(message: message),
        ExamDetailLoaded(:final exam, :final lastAttemptScore) => _DetailBody(
          exam: exam,
          lastAttemptScore: lastAttemptScore,
        ),
      },
    );
  }
}

// ── Loading Scaffold ──────────────────────────────────────────────────────────
class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: Center(child: CircularProgressIndicator(color: Color(0xFFF15A22))),
    );
  }
}

// ── Error Scaffold ────────────────────────────────────────────────────────────
class _ErrorScaffold extends StatelessWidget {
  final String message;
  const _ErrorScaffold({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: BackButton(
          color: const Color(0xFFF15A22),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Error Loading Exam',
          style: TextStyle(
            color: Color(0xFF0B1C30),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Color(0xFFBA1A1A),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF485F84), fontSize: 15),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF15A22),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Main Detail Body ──────────────────────────────────────────────────────────
class _DetailBody extends StatelessWidget {
  final ExamModel exam;
  final String lastAttemptScore;
  const _DetailBody({required this.exam, required this.lastAttemptScore});

  Widget _buildWebLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        exam.examImageUrl != null &&
                                exam.examImageUrl!.isNotEmpty
                            ? Image.network(
                                exam.examImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) =>
                                    const _BannerFallback(),
                              )
                            : const _BannerFallback(),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withAlpha(178),
                                Colors.black.withAlpha(25),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD14307),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'ACADEMIC SESSION 2026',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                exam.examName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (exam.description.isNotEmpty) ...[
                  const Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: Color(0xFFF15A22),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Instructions',
                        style: TextStyle(
                          color: Color(0xFF0B1C30),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE2BFB4).withAlpha(127),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      exam.description,
                      style: const TextStyle(
                        color: Color(0xFF0B1C30),
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDAD6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFBA1A1A).withAlpha(38),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Color(0xFFBA1A1A),
                        size: 24,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Important Notice',
                              style: TextStyle(
                                color: Color(0xFF93000A),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Once you start, the timer cannot be paused. Ensure you have a stable internet connection and uninterrupted time.',
                              style: TextStyle(
                                color: Color(0xFF93000A),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 24, right: 24, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.gavel_rounded,
                      color: Color(0xFFF15A22),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Exam Information',
                      style: TextStyle(
                        color: Color(0xFF0B1C30),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  children: [
                    _BentoCard(
                      icon: Icons.schedule_outlined,
                      title: 'Duration',
                      value: '${exam.durationMinutes} Mins',
                    ),
                    _BentoCard(
                      icon: Icons.quiz_outlined,
                      title: 'Total Score',
                      value: '${exam.totalScore} Pts',
                    ),
                    _BentoCard(
                      icon: Icons.grade_outlined,
                      title: 'Passing Score',
                      value: '${exam.passingScore} Pts',
                    ),
                    _BentoCard(
                      icon: Icons.replay_outlined,
                      title: 'Max Attempts',
                      value: '${exam.maxAttempts} Times',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDCE9FF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Status',
                        style: TextStyle(
                          color: Color(0xFF0B1C30),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _StatusRow(
                        label: 'Allowed Attempts',
                        value: '${exam.maxAttempts}',
                      ),
                      const Divider(color: Color(0xFFDCE9FF), height: 24),
                      _StatusRow(
                        label: 'Last Attempt Score',
                        value: lastAttemptScore,
                      ),
                      const Divider(color: Color(0xFFDCE9FF), height: 24),
                      _StatusRow(
                        label: 'Access Status',
                        valueWidget: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              exam.isPrivate
                                  ? Icons.lock_outline
                                  : Icons.verified_user_outlined,
                              size: 16,
                              color: exam.isPrivate
                                  ? const Color(0xFFD14307)
                                  : const Color(0xFF2E7D32),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              exam.isPrivate ? 'Private' : 'Verified',
                              style: TextStyle(
                                color: exam.isPrivate
                                    ? const Color(0xFFD14307)
                                    : const Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withAlpha(51)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      BlocProvider(
                        create: (_) => StartExamCubit(),
                        child: _JoinButton(exam: exam),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'By clicking, you agree to the Academic Integrity Policy',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF485F84),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      exam.examImageUrl != null && exam.examImageUrl!.isNotEmpty
                          ? Image.network(
                              exam.examImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) =>
                                  const _BannerFallback(),
                            )
                          : const _BannerFallback(),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withAlpha(178),
                              Colors.black.withAlpha(25),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD14307),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'ACADEMIC SESSION 2026',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              exam.examName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Icon(Icons.gavel_rounded, color: Color(0xFFF15A22), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Exam Information',
                    style: TextStyle(
                      color: Color(0xFF0B1C30),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                children: [
                  _BentoCard(
                    icon: Icons.schedule_outlined,
                    title: 'Duration',
                    value: '${exam.durationMinutes} Mins',
                  ),
                  _BentoCard(
                    icon: Icons.quiz_outlined,
                    title: 'Total Score',
                    value: '${exam.totalScore} Pts',
                  ),
                  _BentoCard(
                    icon: Icons.grade_outlined,
                    title: 'Passing Score',
                    value: '${exam.passingScore} Pts',
                  ),
                  _BentoCard(
                    icon: Icons.replay_outlined,
                    title: 'Max Attempts',
                    value: '${exam.maxAttempts} Times',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDCE9FF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Status',
                      style: TextStyle(
                        color: Color(0xFF0B1C30),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _StatusRow(
                      label: 'Allowed Attempts',
                      value: '${exam.maxAttempts}',
                    ),
                    const Divider(color: Color(0xFFDCE9FF), height: 24),
                    _StatusRow(
                      label: 'Last Attempt Score',
                      value: lastAttemptScore,
                    ),
                    const Divider(color: Color(0xFFDCE9FF), height: 24),
                    _StatusRow(
                      label: 'Access Status',
                      valueWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            exam.isPrivate
                                ? Icons.lock_outline
                                : Icons.verified_user_outlined,
                            size: 16,
                            color: exam.isPrivate
                                ? const Color(0xFFD14307)
                                : const Color(0xFF2E7D32),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            exam.isPrivate ? 'Private' : 'Verified',
                            style: TextStyle(
                              color: exam.isPrivate
                                  ? const Color(0xFFD14307)
                                  : const Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (exam.description.isNotEmpty) ...[
                const Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: Color(0xFFF15A22),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Instructions',
                      style: TextStyle(
                        color: Color(0xFF0B1C30),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2BFB4).withAlpha(127),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    exam.description,
                    style: const TextStyle(
                      color: Color(0xFF0B1C30),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDAD6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFBA1A1A).withAlpha(38),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: Color(0xFFBA1A1A),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Important Notice',
                            style: TextStyle(
                              color: Color(0xFF93000A),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Once you start, the timer cannot be paused. Ensure you have a stable internet connection and uninterrupted time.',
                            style: TextStyle(
                              color: Color(0xFF93000A),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.withAlpha(51), width: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocProvider(
                    create: (_) => StartExamCubit(),
                    child: _JoinButton(exam: exam),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'By clicking, you agree to the Academic Integrity Policy',
                    style: TextStyle(
                      color: Color(0xFF485F84),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF15A22)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Exam Preview',
          style: TextStyle(
            color: Color(0xFFF15A22),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuC62lrT4ESydOiLxLunjPK1W-yczpIbpFphthewwnc2lXW38mzMFfNxsOJNUUfipfG0KPgl7T1Eq0yqYiTsMxFpfj8PceZ74h1nYEjgQTHu6BCkty0SfON128LuuqY_6fAUZ5EPajsgjLzGoae_PxBcKSUhJYto2qjAgJyPiQjxROsQD-00OOp735uHZp0tzicdi8EnY7E_M2OVh496QvePUn3ze9mG2wN0Vlcw_0n6NaNLe_WTBoxJhYn9xzvnLwNikFenLmoEg-n_',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(
                    Icons.account_circle,
                    size: 32,
                    color: Color(0xFF485F84),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 850) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: _buildWebLayout(context),
              ),
            );
          } else {
            return _buildMobileLayout(context);
          }
        },
      ),
    );
  }
}

// ── Bento Card ────────────────────────────────────────────────────────────────
class _BentoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _BentoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2BFB4).withAlpha(102)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF485F84)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF485F84),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF0B1C30),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Status Row ────────────────────────────────────────────────────────────────
class _StatusRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _StatusRow({required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF485F84), fontSize: 14),
        ),
        if (valueWidget != null)
          valueWidget!
        else
          Text(
            value ?? '',
            style: const TextStyle(
              color: Color(0xFF0B1C30),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
      ],
    );
  }
}

// ── Banner Fallback ──────────────────────────────────────────────────────────
class _BannerFallback extends StatelessWidget {
  const _BannerFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF15A22), Color(0xFFD14307)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

// ── Join Button (Bắt đầu thi) ────────────────────────────────────────────────
class _JoinButton extends StatelessWidget {
  final ExamModel exam;
  const _JoinButton({required this.exam});

  void _showAccessCodeDialog(BuildContext parentContext, String? errorMessage) {
    final codeController = TextEditingController();
    showDialog<void>(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.lock_outline_rounded, color: Color(0xFFF15A22)),
              const SizedBox(width: 8),
              const Text(
                'Access Code Required',
                style: TextStyle(
                  color: Color(0xFF0B1C30),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please enter the access code provided by your teacher to start the exam.',
                style: TextStyle(color: Color(0xFF485F84), fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                autofocus: true,
                style: const TextStyle(color: Color(0xFF0B1C30)),
                decoration: InputDecoration(
                  labelText: 'Access Code',
                  labelStyle: const TextStyle(color: Color(0xFF485F84)),
                  errorText: errorMessage,
                  filled: true,
                  fillColor: const Color(0xFFFAFAFA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                parentContext.read<StartExamCubit>().reset();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF485F84),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF15A22),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final code = codeController.text.trim();
                if (code.isNotEmpty) {
                  Navigator.of(dialogContext).pop();
                  parentContext.read<StartExamCubit>().checkAndStartExam(
                    examId: exam.examId,
                    accessCode: code,
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StartExamCubit, StartExamState>(
      listener: (context, state) {
        // THÀNH CÔNG: Người dùng có quyền truy cập trực tiếp, chuyển sang phòng thi
        if (state is StartExamSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.startResponse.isResume
                    ? '🔄 Resuming previous attempt...'
                    : '✅ Exam started successfully!',
              ),
              backgroundColor: const Color(0xFF2E7D32),
            ),
          );

          final cubit = context.read<StartExamCubit>();
          // Điều hướng Student sang màn hình làm bài thi chính thức
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExamTakingScreen(
                attemptId: state.startResponse.attemptId,
                durationMinutes: exam.durationMinutes,
                questions: state.questions,
                examName: exam.examName,
                attemptStartTime: state.attemptStartTime,
                examEndTime: exam.endTime,
              ),
            ),
          ).then((_) {
            if (context.mounted && !cubit.isClosed) {
              cubit.reset();
            }
          });
        }

        // YÊU CẦU MẬT MÃ: Hiển thị hộp thoại Dialog để nhập Access Code
        if (state is StartExamCodeRequired) {
          _showAccessCodeDialog(context, state.errorMessage);
        }

        // THẤT BẠI: Hiện lỗi (không có quyền, hết hạn đăng ký) và reset trạng thái Cubit
        if (state is StartExamFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFBA1A1A),
            ),
          );
          context.read<StartExamCubit>().reset();
        }
      },
      builder: (context, state) {
        final loading = state is StartExamLoading;
        final statusMsg = state is StartExamLoading
            ? state.statusMessage
            : 'Start Exam';

        final buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF15A22),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );

        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: buttonStyle,
            onPressed: loading
                ? null
                : () {
                    // Bước 1: Gọi check-access với accessCode = null
                    context.read<StartExamCubit>().checkAndStartExam(
                      examId: exam.examId,
                      accessCode: null,
                    );
                  },
            child: loading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        statusMsg,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Start Exam',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.play_arrow, size: 20),
                    ],
                  ),
          ),
        );
      },
    );
  }
}