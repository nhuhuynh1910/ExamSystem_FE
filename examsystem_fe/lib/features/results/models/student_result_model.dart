import '../../exam/models/exam_submit_response.dart';

/// Model đại diện cho kết quả bài thi của Sinh viên.
class StudentResultModel {
  final int examId;
  final String examName;
  final String? subjectName;
  final int attemptId;
  final int attemptNumber;
  final double score;
  final double totalScore;
  final double passingScore;
  final bool isPassed;
  final DateTime? submitTime;
  final DateTime startTime;
  final int totalQuestions;
  final int correctAnswers;

  StudentResultModel({
    required this.examId,
    required this.examName,
    this.subjectName,
    required this.attemptId,
    required this.attemptNumber,
    required this.score,
    required this.totalScore,
    required this.passingScore,
    required this.isPassed,
    this.submitTime,
    required this.startTime,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
  });

  factory StudentResultModel.fromJson(Map<String, dynamic> json) {
    final questions = json['questions'] as List? ?? [];
    final correctCount = questions.where((q) {
      if (q is Map) {
        return q['isCorrect'] == true;
      }
      return false;
    }).length;

    return StudentResultModel(
      examId: (json['examId'] as num?)?.toInt() ?? 0,
      examName: json['examName'] as String? ?? 'Bài thi',
      subjectName: json['subjectName'] as String?,
      attemptId: (json['attemptId'] as num?)?.toInt() ?? 0,
      attemptNumber: (json['attemptNumber'] as num?)?.toInt() ?? 1,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 10.0,
      passingScore: (json['passingScore'] as num?)?.toDouble() ?? 5.0,
      isPassed: json['isPassed'] as bool? ?? false,
      submitTime: json['submitTime'] != null
          ? DateTime.tryParse(json['submitTime'].toString())?.toLocal()
          : null,
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'].toString())?.toLocal() ??
              DateTime.now()
          : DateTime.now(),
      totalQuestions: questions.length,
      correctAnswers: correctCount,
    );
  }

  double get scorePercentage =>
      totalScore > 0 ? (score / totalScore) * 100 : 0.0;

  ExamSubmitResponse toSubmitResponse() {
    return ExamSubmitResponse(
      attemptId: attemptId,
      examId: examId,
      attemptNumber: attemptNumber,
      status: 'Submitted',
      startTime: startTime,
      submitTime: submitTime ?? DateTime.now(),
      score: score,
      passingScore: passingScore,
      totalScore: totalScore,
      isPassed: isPassed,
      isAutoSubmitted: false,
      answeredQuestions: correctAnswers,
      totalQuestions: totalQuestions,
    );
  }
}
