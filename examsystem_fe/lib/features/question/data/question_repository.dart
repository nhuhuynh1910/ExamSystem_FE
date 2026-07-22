import 'question_api.dart';
import '../models/question_model.dart';
import '../../exam/models/subject_model.dart';

class QuestionRepository {
  final QuestionApi _api = QuestionApi();

  Future<List<SubjectModel>> getSubjects() => _api.getSubjects();
  Future<List<SubjectModel>> getTeacherSubjects() => _api.getTeacherSubjects();

  Future<List<QuestionModel>> getQuestions({Map<String, dynamic>? queryParameters}) {
    return _api.getQuestions(queryParameters: queryParameters);
  }

  Future<void> publishQuestion(int id) {
    return _api.publishQuestion(id);
  }

  Future<void> draftQuestion(int id) {
    return _api.draftQuestion(id);
  }

  Future<QuestionModel> createQuestion(Map<String, dynamic> data) => _api.createQuestion(data);
  Future<void> addOption(int questionId, Map<String, dynamic> data) => _api.addOption(questionId, data);
}
