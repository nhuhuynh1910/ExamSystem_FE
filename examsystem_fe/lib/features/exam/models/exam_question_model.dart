import 'exam_question_option_model.dart';

class ExamQuestionModel {
  final int examQuestionId;
  final int questionId;
  final int questionOrder;
  final double score;
  final String content;
  final String questionType;
  final String difficulty;
  final String? explanation;
  final List<ExamQuestionOptionModel> options;

  const ExamQuestionModel({
    required this.examQuestionId,
    required this.questionId,
    required this.questionOrder,
    required this.score,
    required this.content,
    required this.questionType,
    required this.difficulty,
    this.explanation,
    required this.options,
  });

  factory ExamQuestionModel.fromJson(Map<String, dynamic> json) {
    return ExamQuestionModel(
      examQuestionId: json['examQuestionId'] ?? 0,
      questionId: json['questionId'] ?? 0,
      questionOrder: json['questionOrder'] ?? 0,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      content: json['content'] ?? '',
      questionType: json['questionType'] ?? '',
      difficulty: json['difficulty'] ?? '',
      explanation: json['explanation'],
      options: (json['options'] as List? ?? [])
          .map((e) => ExamQuestionOptionModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'examQuestionId': examQuestionId,
    'questionId': questionId,
    'questionOrder': questionOrder,
    'score': score,
    'content': content,
    'questionType': questionType,
    'difficulty': difficulty,
    'explanation': explanation,
    'options': options.map((e) => e.toJson()).toList(),
  };
}
