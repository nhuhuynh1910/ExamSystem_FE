import 'attempt_api.dart';

class AttemptRepository {
  final AttemptApi _api = AttemptApi();

  Future<Map<String, dynamic>> checkAccess(int examId, String? accessCode) =>
      _api.checkAccess(examId, accessCode);

  Future<Map<String, dynamic>> startExam(int examId, String? accessCode) =>
      _api.startExam(examId, accessCode);

  Future<void> saveAnswer(int attemptId, int questionId, List<int> selectedOptionIds) =>
      _api.saveAnswer(attemptId, questionId, selectedOptionIds);

  Future<Map<String, dynamic>> submitExam(int attemptId) =>
      _api.submitExam(attemptId);
}
