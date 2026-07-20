import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/utils/token_storage.dart';

// ════════════════════════════════════════════════════════════════════════════
// StudentResultsBody — Màn hình kết quả thi dành cho Student.
//
// Widget này KHÔNG có Scaffold, AppBar hay BottomNavigationBar.
// Được nhúng vào IndexedStack trong StudentDashboardScreen (index = 2).
// ════════════════════════════════════════════════════════════════════════════
class StudentResultsBody extends StatefulWidget {
  const StudentResultsBody({super.key});

  @override
  State<StudentResultsBody> createState() => _StudentResultsBodyState();
}

class _StudentResultsBodyState extends State<StudentResultsBody> {
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final userId = await TokenStorage.getUserId();
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _error = 'Không xác định được người dùng.';
        });
        return;
      }

      // TODO: Đổi thành API thật khi Backend hỗ trợ endpoint lấy danh sách kết quả của Student.
      // Hiện tại Backend chưa có API /api/attempts/student/{id} nên trả về 404.
      // Mock data:
      await Future.delayed(const Duration(seconds: 1));

      List<Map<String, dynamic>> results = [
        {
          'examName': 'Midterm Exam - Software Engineering',
          'subjectName': 'Software Engineering',
          'score': 85.5,
          'totalQuestions': 40,
          'correctAnswers': 34,
          'submittedAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          'isPassed': true,
        },
        {
          'examName': 'Quiz 1 - Distributed Systems',
          'subjectName': 'Distributed Systems',
          'score': 45.0,
          'totalQuestions': 20,
          'correctAnswers': 9,
          'submittedAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          'isPassed': false,
        },
        {
          'examName': 'Final Exam - Mobile App Development',
          'subjectName': 'Mobile App Development',
          'score': 92.0,
          'totalQuestions': 50,
          'correctAnswers': 46,
          'submittedAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
          'isPassed': true,
        },
      ];

      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Không thể tải kết quả. Vui lòng thử lại.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF15A22)),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadResults,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF15A22),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard_outlined, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Chưa có kết quả nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D3557),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kết quả các bài thi đã hoàn thành\nsẽ hiển thị tại đây.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadResults,
      color: const Color(0xFFF15A22),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: _results.length,
        itemBuilder: (context, index) => _buildResultCard(_results[index]),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    final examName = result['examName']?.toString() ?? 'Bài thi';
    final subjectName = result['subjectName']?.toString() ?? '';
    final score = result['score'];
    final totalQuestions = result['totalQuestions'] ?? 0;
    final correctAnswers = result['correctAnswers'] ?? 0;
    final submittedAtStr = result['submittedAt']?.toString();
    final isPassed = result['isPassed'] == true;

    DateTime? submittedAt;
    if (submittedAtStr != null) {
      submittedAt = DateTime.tryParse(submittedAtStr);
    }

    // Tính phần trăm điểm
    final double scorePercent = (score != null)
        ? (score is num ? score.toDouble() : double.tryParse(score.toString()) ?? 0.0)
        : 0.0;

    final Color scoreColor = isPassed
        ? const Color(0xFF10B981) // green
        : const Color(0xFFEF4444); // red

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Score circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor.withValues(alpha: 0.1),
                border: Border.all(color: scoreColor, width: 2),
              ),
              child: Center(
                child: Text(
                  '${scorePercent.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: scoreColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Exam info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    examName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subjectName.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subjectName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFF15A22),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '$correctAnswers / $totalQuestions câu đúng',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  if (submittedAt != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(submittedAt),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Pass/Fail badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isPassed ? 'Đạt' : 'Chưa đạt',
                style: TextStyle(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
