import 'package:dio/dio.dart';

class AddExamQuestionRequest {
  final int questionId;
  final int? questionOrder;
  final double? score;

  const AddExamQuestionRequest({
    required this.questionId,
    this.questionOrder,
    this.score,
  });

  Map<String, dynamic> toJson() {
    return {
      'QuestionId': questionId,
      if (questionOrder != null) 'QuestionOrder': questionOrder,
      if (score != null) 'Score': score,
    };
  }

  FormData toFormData() {
    return FormData.fromMap(toJson());
  }
}
