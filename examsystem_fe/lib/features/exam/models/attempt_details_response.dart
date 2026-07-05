import 'question_model.dart';

/// Map từ response của GET /api/attempts/{attemptId}
class AttemptDetailsResponse {
  final int attemptId;
  final int examId;
  final String examName;
  final int studentId;
  final int attemptNumber;
  final DateTime startTime;
  final String status;
  final List<QuestionModel> questions;

  AttemptDetailsResponse({
    required this.attemptId,
    required this.examId,
    required this.examName,
    required this.studentId,
    required this.attemptNumber,
    required this.startTime,
    required this.status,
    required this.questions,
  });

  factory AttemptDetailsResponse.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'] as List<dynamic>? ?? [];
    return AttemptDetailsResponse(
      attemptId: (json['attemptId'] as num?)?.toInt() ?? 0,
      examId: (json['examId'] as num?)?.toInt() ?? 0,
      examName: json['examName'] as String? ?? '',
      studentId: (json['studentId'] as num?)?.toInt() ?? 0,
      attemptNumber: (json['attemptNumber'] as num?)?.toInt() ?? 0,
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      status: json['status'] as String? ?? '',
      questions: rawQuestions.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
