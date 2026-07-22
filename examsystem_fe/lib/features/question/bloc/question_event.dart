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
