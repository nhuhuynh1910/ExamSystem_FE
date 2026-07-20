/// Model representing the response from the POST /api/attempts/{attemptId}/submit endpoint.
class ExamSubmitResponse {
  final int attemptId;
  final int examId;
  final int attemptNumber;
  final String status;
  final DateTime startTime;
  final DateTime submitTime;
  final double score;
  final double passingScore;
  final double totalScore;
  final bool isPassed;
  final bool isAutoSubmitted;
  final int answeredQuestions;
  final int totalQuestions;

  ExamSubmitResponse({
    required this.attemptId,
    required this.examId,
    required this.attemptNumber,
    required this.status,
    required this.startTime,
    required this.submitTime,
    required this.score,
    required this.passingScore,
    required this.totalScore,
    required this.isPassed,
    required this.isAutoSubmitted,
    required this.answeredQuestions,
    required this.totalQuestions,
  });

  factory ExamSubmitResponse.fromJson(Map<String, dynamic> json) {
    return ExamSubmitResponse(
      attemptId: (json['attemptId'] as num?)?.toInt() ?? 0,
      examId: (json['examId'] as num?)?.toInt() ?? 0,
      attemptNumber: (json['attemptNumber'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '',
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      submitTime: json['submitTime'] != null
          ? DateTime.tryParse(json['submitTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      passingScore: (json['passingScore'] as num?)?.toDouble() ?? 0.0,
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
      isPassed: json['isPassed'] as bool? ?? false,
      isAutoSubmitted: json['isAutoSubmitted'] as bool? ?? false,
      answeredQuestions: (json['answeredQuestions'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
    );
  }
}
