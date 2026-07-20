import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/question_model_khanh.dart';
import '../models/subject_model_khanh.dart';

class QuestionApiKhanh {
  QuestionModelKhanh _parseQuestion(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final wrappedData = responseData['data'];

      if (wrappedData is Map<String, dynamic>) {
        return QuestionModelKhanh.fromJson(wrappedData);
      }

      return QuestionModelKhanh.fromJson(responseData);
    }

    throw const FormatException(
      'Invalid question response format',
    );
  }

  List<QuestionModelKhanh> _parseQuestionList(
      dynamic responseData,
      ) {
    if (responseData is List) {
      return responseData
          .map(
            (item) => QuestionModelKhanh.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList();
    }

    if (responseData is Map<String, dynamic>) {
      final items = responseData['items'] ??
          responseData['data'] ??
          responseData['questions'];

      if (items is List) {
        return items
            .map(
              (item) => QuestionModelKhanh.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
            .toList();
      }
    }

    throw const FormatException(
      'Invalid questions response format',
    );
  }

  Future<QuestionModelKhanh> updateQuestion({
    required int questionId,
    required Map<String, dynamic> body,
  }) async {
    final response = await DioClient.instance.put(
      '${ApiConstants.questions}/$questionId',
      data: body,
    );

    return _parseQuestion(response.data);
  }

  Future<QuestionModelKhanh> createQuestion(
      Map<String, dynamic> body,
      ) async {
    final response = await DioClient.instance.post(
      ApiConstants.questions,
      data: body,
    );

    return _parseQuestion(response.data);
  }

  Future<void> addOption({
    required int questionId,
    required Map<String, dynamic> body,
  }) async {
    await DioClient.instance.post(
      '${ApiConstants.questions}/$questionId/options',
      data: body,
    );
  }

  Future<void> updateOption({
    required int optionId,
    required Map<String, dynamic> body,
  }) async {
    await DioClient.instance.put(
      '${ApiConstants.questions}/options/$optionId',
      data: body,
    );
  }

  Future<void> deleteOption(int optionId) async {
    await DioClient.instance.delete(
      '${ApiConstants.questions}/options/$optionId',
    );
  }

  Future<List<SubjectModelKhanh>> getSubjects() async {
    final response = await DioClient.instance.get(
      ApiConstants.subjects,
    );

    final responseData = response.data;

    dynamic subjectsData = responseData;

    if (responseData is Map<String, dynamic>) {
      subjectsData = responseData['data'] ??
          responseData['items'] ??
          responseData['subjects'];
    }

    if (subjectsData is List) {
      return subjectsData
          .map(
            (item) => SubjectModelKhanh.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList();
    }

    throw const FormatException(
      'Invalid subjects response format',
    );
  }

  Future<List<QuestionModelKhanh>> getQuestions({
    int pageNumber = 1,
    int pageSize = 10,
    int? subjectId,
    String? difficulty,
    String? status,
    String? questionType,
    String? search,
  }) async {
    final response = await DioClient.instance.get(
      ApiConstants.questions,
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (subjectId != null) 'subjectId': subjectId,
        if (difficulty != null && difficulty.isNotEmpty)
          'difficulty': difficulty,
        if (status != null && status.isNotEmpty)
          'status': status,
        if (questionType != null && questionType.isNotEmpty)
          'questionType': questionType,
        if (search != null && search.trim().isNotEmpty)
          'search': search.trim(),
      },
    );

    return _parseQuestionList(response.data);
  }

  Future<void> deleteQuestion(int questionId) async {
    await DioClient.instance.delete(
      '${ApiConstants.questions}/$questionId',
    );
  }

  Future<void> publishQuestion(int questionId) async {
    await DioClient.instance.put(
      '${ApiConstants.questions}/$questionId/publish',
    );
  }

  Future<void> draftQuestion(int questionId) async {
    await DioClient.instance.put(
      '${ApiConstants.questions}/$questionId/draft',
    );
  }
}