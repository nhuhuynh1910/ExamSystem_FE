class QuestionModel {
  final int questionId;
  final int subjectId;
  final String subjectName;
  final int teacherId;
  final String teacherName;
  final String content;
  final String questionType;
  final String difficulty;
  final double score;
  final String status;
  final String? explanation;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<QuestionOptionModel> options;

  QuestionModel({
    required this.questionId,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.teacherName,
    required this.content,
    required this.questionType,
    required this.difficulty,
    required this.score,
    required this.status,
    this.explanation,
    required this.createdAt,
    this.updatedAt,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      questionId: json['questionId'] ?? 0,
      subjectId: json['subjectId'] ?? 0,
      subjectName: json['subjectName'] ?? '',
      teacherId: json['teacherId'] ?? 0,
      teacherName: json['teacherName'] ?? '',
      content: json['content'] ?? '',
      questionType: json['questionType'] ?? '',
      difficulty: json['difficulty'] ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      explanation: json['explanation'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      options: (json['options'] as List? ?? [])
          .map((e) => QuestionOptionModel.fromJson(e))
          .toList(),
    );
  }
}

class QuestionOptionModel {
  final int optionId;
  final String optionText;
  final bool isCorrect;
  final int optionOrder;

  QuestionOptionModel({
    required this.optionId,
    required this.optionText,
    required this.isCorrect,
    required this.optionOrder,
  });

  factory QuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return QuestionOptionModel(
      optionId: json['optionId'] ?? 0,
      optionText: json['optionText'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
      optionOrder: json['optionOrder'] ?? 0,
    );
  }
}
