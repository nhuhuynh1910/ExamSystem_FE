import 'package:dio/dio.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../exam/models/subject_model.dart';
import '../models/question_model.dart';

class QuestionApi {
  final Dio _dio = DioClient.instance;

  //======================== PARSE ========================

  QuestionModel _parseQuestion(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];

      if (data is Map<String, dynamic>) {
        return QuestionModel.fromJson(data);
      }

      return QuestionModel.fromJson(responseData);
    }

    throw const FormatException(
      'Invalid question response format',
    );
  }


  List<QuestionModel> _parseQuestionList(dynamic responseData) {
    if (responseData is List) {
      return responseData
          .map((e) => QuestionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (responseData is Map<String, dynamic>) {
      // Handle PagedResultDto or other wrapper structures
      final data = responseData['items'] ??
          responseData['data'] ??
          responseData['questions'];

      if (data is List) {
        return data
            .map((e) => QuestionModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }

    return []; // Return empty list instead of throwing to be more robust
  }

  //======================== SUBJECT ========================

  Future<List<SubjectModel>> getSubjects() async {
    final response = await _dio.get(ApiConstants.subjects);
    return _parseSubjectList(response.data);
  }

  Future<List<SubjectModel>> getTeacherSubjects() async {
    // Current BE uses teacher-requests/my-requests to see which subjects a teacher is assigned to.
    final response = await _dio.get(ApiConstants.teacherRequestsMy);

    final data = response.data;
    if (data is List) {
      // If the response is a list of BaoTecherRequestResponseDto, map them to SubjectModel.
      // We only care about Approved requests.
      return data
          .where((e) => e['status'] == 'Approved')
          .map((e) => SubjectModel(
                subjectId: e['subjectId'] ?? 0,
                subjectName: e['subjectName'] ?? 'Unknown',
                isActive: true,
              ))
          .toList();
    }
    
    // Fallback to all subjects if the above doesn't yield anything or structure is different
    return getSubjects();
  }

  List<SubjectModel> _parseSubjectList(dynamic responseData) {
    if (responseData is List) {
      return responseData
          .map((e) => SubjectModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (responseData is Map<String, dynamic>) {
      final data = responseData['items'] ?? responseData['data'] ?? responseData['subjects'];
      if (data is List) {
        return data
            .map((e) => SubjectModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
    return [];
  }




  //======================== QUESTION ========================


  Future<List<QuestionModel>> getQuestions({

    int pageNumber = 1,

    int pageSize = 10,

    int? subjectId,

    String? difficulty,

    String? status,

    String? questionType,

    String? search,

  }) async {


    final response = await _dio.get(

      ApiConstants.questions,

      queryParameters: {


        "pageNumber": pageNumber,

        "pageSize": pageSize,


        if(subjectId != null)
          "subjectId": subjectId,


        if(difficulty != null && difficulty.isNotEmpty)
          "difficulty": difficulty,


        if(status != null && status.isNotEmpty)
          "status": status,


        if(questionType != null && questionType.isNotEmpty)
          "questionType": questionType,


        if(search != null && search.trim().isNotEmpty)
          "search": search.trim(),

      },

    );


    return _parseQuestionList(
      response.data,
    );

  }




  Future<QuestionModel> createQuestion(
      Map<String,dynamic> data
      ) async {


    final response = await _dio.post(

      ApiConstants.questions,

      data:data,

    );


    return _parseQuestion(
      response.data,
    );

  }




  Future<QuestionModel> updateQuestion(

      int questionId,

      Map<String,dynamic> data,

      ) async {


    final response = await _dio.put(

      '${ApiConstants.questions}/$questionId',

      data:data,

    );


    return _parseQuestion(
      response.data,
    );

  }





  Future<void> deleteQuestion(
      int questionId
      ) async {


    await _dio.delete(

      '${ApiConstants.questions}/$questionId',

    );

  }





  Future<void> publishQuestion(
      int questionId
      ) async {


    await _dio.put(

      '${ApiConstants.questions}/$questionId/publish',

    );

  }





  Future<void> draftQuestion(
      int questionId
      ) async {


    await _dio.put(

      '${ApiConstants.questions}/$questionId/draft',

    );

  }




  //======================== OPTION ========================


  Future<void> addOption(

      int questionId,

      Map<String,dynamic> data,

      ) async {


    await _dio.post(

      '${ApiConstants.questions}/$questionId/options',

      data:data,

    );

  }





  Future<void> updateOption(

      int optionId,

      Map<String,dynamic> data,

      ) async {


    await _dio.put(

      '${ApiConstants.questions}/options/$optionId',

      data:data,

    );

  }





  Future<void> deleteOption(

      int optionId

      ) async {


    await _dio.delete(

      '${ApiConstants.questions}/options/$optionId',

    );

  }

}