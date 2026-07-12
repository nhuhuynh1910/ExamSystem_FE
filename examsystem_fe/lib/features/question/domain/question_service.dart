import '../data/question_repository.dart';
import '../models/question_model.dart';
import '../../exam/models/subject_model.dart';

class QuestionService {
  final QuestionRepository _repository;

  QuestionService(this._repository);

  Future<List<SubjectModel>> getSubjects() => _repository.getSubjects();

  Future<List<QuestionModel>> getQuestions({Map<String, dynamic>? queryParameters}) {
    return _repository.getQuestions(queryParameters: queryParameters);
  }

  Future<void> publishQuestion(int id) {
    return _repository.publishQuestion(id);
  }

  Future<void> draftQuestion(int id) {
    return _repository.draftQuestion(id);
  }

  Future<void> createQuestionWithOptions(Map<String, dynamic> qData, List<Map<String, dynamic>> options) async {
    final question = await _repository.createQuestion(qData);
    for (var opt in options) {
      await _repository.addOption(question.questionId, opt);
    }
  }
}
