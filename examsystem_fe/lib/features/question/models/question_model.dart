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

  // Có hoặc không tùy API
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? rowVersion;

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
    this.createdAt,
    this.updatedAt,
    this.rowVersion,
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
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      rowVersion: json['rowVersion'],
      options: (json['options'] as List? ?? [])
          .map((e) => QuestionOptionModel.fromJson(e))
          .toList(),
    );
  }
}

class QuestionOptionModel {
  final int optionId;
  final int? questionId;
  final String optionText;
  final bool? isCorrect;
  final int optionOrder;
  final String? rowVersion;

  QuestionOptionModel({
    required this.optionId,
    this.questionId,
    required this.optionText,
    this.isCorrect,
    required this.optionOrder,
    this.rowVersion,
  });

  factory QuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return QuestionOptionModel(
      optionId: json['optionId'] ?? 0,
      questionId: json['questionId'],
      optionText: json['optionText'] ?? '',
      isCorrect: json['isCorrect'],
      optionOrder: json['optionOrder'] ?? 0,
      rowVersion: json['rowVersion'],
    );
  }
}