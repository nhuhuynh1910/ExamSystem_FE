class QuestionModel {
  final int examQuestionId;
  final int questionId;
  final int questionOrder;
  final double score;
  final String content;
  final String questionType;
  final String difficulty;
  final String explanation;
  final List<OptionModel> options;
  final bool hasAnswer;
  final List<int> selectedOptionIds;

  const QuestionModel({
    required this.examQuestionId,
    required this.questionId,
    required this.questionOrder,
    required this.score,
    required this.content,
    required this.questionType,
    required this.difficulty,
    required this.explanation,
    required this.options,
    this.hasAnswer = false,
    this.selectedOptionIds = const [],
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? [];
    final rawSelectedOptionIds = json['selectedOptionIds'] as List<dynamic>? ?? [];
    return QuestionModel(
      examQuestionId: (json['examQuestionId'] as num?)?.toInt() ?? 0,
      questionId:     (json['questionId']     as num?)?.toInt() ?? 0,
      questionOrder:  (json['questionOrder']  as num?)?.toInt() ?? 0,
      score:          (json['score']          as num?)?.toDouble() ?? 0.0,
      content:        json['content']         as String? ?? '',
      questionType:   json['questionType']    as String? ?? '',
      difficulty:     json['difficulty']      as String? ?? '',
      explanation:    json['explanation']     as String? ?? '',
      options:        rawOptions.map((e) => OptionModel.fromJson(e as Map<String, dynamic>)).toList(),
      hasAnswer:      json['hasAnswer']       as bool? ?? false,
      selectedOptionIds: rawSelectedOptionIds.map((e) => (e as num).toInt()).toList(),
    );
  }
}

class OptionModel {
  final int optionId;
  final String optionText;
  final bool isCorrect;
  final int optionOrder;
  final bool isSelected;

  const OptionModel({
    required this.optionId,
    required this.optionText,
    required this.isCorrect,
    required this.optionOrder,
    this.isSelected = false,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      optionId:   (json['optionId']   as num?)?.toInt() ?? 0,
      optionText: json['optionText'] as String? ?? '',
      isCorrect:  json['isCorrect']  as bool? ?? false,
      optionOrder: (json['optionOrder'] as num?)?.toInt() ?? 0,
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }
}
