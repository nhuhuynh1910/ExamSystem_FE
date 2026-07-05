/// Map từ ExamStartResponse trong BE — trả về bởi POST /api/exams/{examId}/start.
class ExamStartResponse {
  final int attemptId;
  final int examId;
  final int attemptNumber;
  final DateTime startTime;
  final String status;
  final int questionCount;
  final bool isResume;

  const ExamStartResponse({
    required this.attemptId,
    required this.examId,
    required this.attemptNumber,
    required this.startTime,
    required this.status,
    required this.questionCount,
    required this.isResume,
  });

  factory ExamStartResponse.fromJson(Map<String, dynamic> json) {
    return ExamStartResponse(
      attemptId:     (json['attemptId']     as num?)?.toInt() ?? 0,
      examId:        (json['examId']        as num?)?.toInt() ?? 0,
      attemptNumber: (json['attemptNumber'] as num?)?.toInt() ?? 0,
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      status:        json['status']         as String? ?? '',
      questionCount: (json['questionCount'] as num?)?.toInt() ?? 0,
      isResume:      json['isResume']       as bool? ?? false,
    );
  }
}
