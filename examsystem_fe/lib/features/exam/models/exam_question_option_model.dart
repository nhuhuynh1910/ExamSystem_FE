class ExamQuestionOptionModel {
  final int optionId;
  final String optionText;
  final bool? isCorrect;
  final int optionOrder;

  const ExamQuestionOptionModel({
    required this.optionId,
    required this.optionText,
    this.isCorrect,
    required this.optionOrder,
  });

  factory ExamQuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return ExamQuestionOptionModel(
      optionId: json['optionId'] ?? 0,
      optionText: json['optionText'] ?? '',
      isCorrect: json['isCorrect'],
      optionOrder: json['optionOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'optionId': optionId,
    'optionText': optionText,
    'isCorrect': isCorrect,
    'optionOrder': optionOrder,
  };
}
