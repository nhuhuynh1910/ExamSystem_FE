abstract class QuestionEvent {
  const QuestionEvent();
}

class LoadSubjectsEvent extends QuestionEvent {
  const LoadSubjectsEvent();
}

class LoadQuestionsEvent extends QuestionEvent {
  final Map<String, dynamic>? queryParameters;
  const LoadQuestionsEvent({this.queryParameters});
}

class PublishQuestionEvent extends QuestionEvent {
  final int questionId;
  const PublishQuestionEvent(this.questionId);
}

class DraftQuestionEvent extends QuestionEvent {
  final int questionId;
  const DraftQuestionEvent(this.questionId);
}

class CreateQuestionEvent extends QuestionEvent {
  final Map<String, dynamic> data;
  final List<Map<String, dynamic>> options;
  const CreateQuestionEvent(this.data, this.options);
}

class UpdateQuestionEvent extends QuestionEvent {
  final int questionId;
  final Map<String, dynamic> data;
  final List<Map<String, dynamic>> newOptions;
  final List<Map<String, dynamic>> updatedOptions;
  final List<int> deletedOptionIds;

  const UpdateQuestionEvent({
    required this.questionId,
    required this.data,
    required this.newOptions,
    required this.updatedOptions,
    required this.deletedOptionIds,
  });
}

class DeleteQuestionEvent extends QuestionEvent {
  final int questionId;
  const DeleteQuestionEvent(this.questionId);
}
