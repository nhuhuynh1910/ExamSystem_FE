import '../data/question_api_khanh.dart';
import '../models/question_model_khanh.dart';

class QuestionRepositoryKhanh {
  final QuestionApiKhanh api;

  QuestionRepositoryKhanh(this.api);

  Future<List<QuestionModelKhanh>> getQuestions({
    int pageNumber = 1,
    int pageSize = 10,
    int? subjectId,
    String? difficulty,
    String? status,
    String? questionType,
    String? search,
  }) {
    return api.getQuestions(
      pageNumber: pageNumber,
      pageSize: pageSize,
      subjectId: subjectId,
      difficulty: difficulty,
      status: status,
      questionType: questionType,
      search: search,
    );
  }

  Future<void> deleteQuestion(int id) {
    return api.deleteQuestion(id);
  }

  Future<void> publishQuestion(int id) {
    return api.publishQuestion(id);
  }

  Future<void> draftQuestion(int id) {
    return api.draftQuestion(id);
  }
}