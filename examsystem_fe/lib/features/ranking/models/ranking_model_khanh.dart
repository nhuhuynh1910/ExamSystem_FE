class RankingModelKhanh {
  final int examId;
  final String examName;
  final int top;
  final List<RankingItemModelKhanh> items;

  RankingModelKhanh({
    required this.examId,
    required this.examName,
    required this.top,
    required this.items,
  });

  factory RankingModelKhanh.fromJson(Map<String, dynamic> json) {
    return RankingModelKhanh(
      examId: json['examId'] ?? 0,
      examName: json['examName'] ?? '',
      top: json['top'] ?? 5,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => RankingItemModelKhanh.fromJson(e))
          .toList(),
    );
  }
}

class RankingItemModelKhanh {
  final int rank;
  final int studentId;
  final String studentName;
  final String username;
  final int attemptId;
  final int attemptNumber;
  final double score;
  final bool isPassed;
  final DateTime startTime;
  final DateTime submitTime;
  final double submitDurationSeconds;

  RankingItemModelKhanh({
    required this.rank,
    required this.studentId,
    required this.studentName,
    required this.username,
    required this.attemptId,
    required this.attemptNumber,
    required this.score,
    required this.isPassed,
    required this.startTime,
    required this.submitTime,
    required this.submitDurationSeconds,
  });

  factory RankingItemModelKhanh.fromJson(Map<String, dynamic> json) {
    return RankingItemModelKhanh(
      rank: json['rank'] ?? 0,
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
      username: json['username'] ?? '',
      attemptId: json['attemptId'] ?? 0,
      attemptNumber: json['attemptNumber'] ?? 0,
      score: (json['score'] ?? 0).toDouble(),
      isPassed: json['isPassed'] ?? false,
      startTime: DateTime.parse(json['startTime']),
      submitTime: DateTime.parse(json['submitTime']),
      submitDurationSeconds:
      (json['submitDurationSeconds'] ?? 0).toDouble(),
    );
  }

  /// Convert seconds to: 45m 52s
  String get durationText {
    final total = submitDurationSeconds.toInt();
    final minutes = total ~/ 60;
    final seconds = total % 60;

    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }
}