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
      'questionId': questionId,
      if (questionOrder != null) 'questionOrder': questionOrder,
      if (score != null) 'score': score,
    };
  }

  FormData toFormData() {
    return FormData.fromMap(toJson());
  }
}
