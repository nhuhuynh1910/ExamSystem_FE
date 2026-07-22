class QuestionOptionModelKhanh {
  final int optionId;
  final int questionId;
  final String optionText;
  final bool? isCorrect;
  final int optionOrder;
  final String? rowVersion;

  QuestionOptionModelKhanh({
    required this.optionId,
    required this.questionId,
    required this.optionText,
    required this.isCorrect,
    required this.optionOrder,
    required this.rowVersion,
  });

  factory QuestionOptionModelKhanh.fromJson(Map<String, dynamic> json) {
    return QuestionOptionModelKhanh(
      optionId: json['optionId'] ?? 0,
      questionId: json['questionId'] ?? 0,
      optionText: json['optionText'] ?? '',
      isCorrect: json['isCorrect'],
      optionOrder: json['optionOrder'] ?? 0,
      rowVersion: json['rowVersion'],
    );
  }
}

class QuestionModelKhanh {
  final int questionId;
  final int subjectId;
  final String subjectName;
  final int teacherId;
  final String teacherName;
  final String content;
  final String questionType;
  final String difficulty;
  final num score;
  final String status;
  final String? explanation;
  final List<QuestionOptionModelKhanh> options;
  final String? rowVersion;

  QuestionModelKhanh({
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
    required this.explanation,
    required this.options,
    required this.rowVersion,
  });

  factory QuestionModelKhanh.fromJson(Map<String, dynamic> json) {
    return QuestionModelKhanh(
      questionId: json['questionId'] ?? 0,
      subjectId: json['subjectId'] ?? 0,
      subjectName: json['subjectName'] ?? '',
      teacherId: json['teacherId'] ?? 0,
      teacherName: json['teacherName'] ?? '',
      content: json['content'] ?? '',
      questionType: json['questionType'] ?? '',
      difficulty: json['difficulty'] ?? '',
      score: json['score'] ?? 0,
      status: json['status'] ?? '',
      explanation: json['explanation'],
      rowVersion: json['rowVersion'],
      options: (json['options'] as List? ?? [])
          .map((e) => QuestionOptionModelKhanh.fromJson(e))
          .toList(),
    );
  }
}