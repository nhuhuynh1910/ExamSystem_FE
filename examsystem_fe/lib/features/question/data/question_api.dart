import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/question_model.dart';
import '../../exam/models/subject_model.dart';

class QuestionApi {
  final Dio _dio = DioClient.instance;

  Future<List<SubjectModel>> getSubjects() async {
    final response = await _dio.get(ApiConstants.subjects);
    // BE trả về trực tiếp mảng List<SubjectResponseDto>
    final List data = response.data is List ? response.data : (response.data['items'] ?? []);
    return data.map((json) => SubjectModel.fromJson(json)).toList();
  }

  Future<List<QuestionModel>> getQuestions({Map<String, dynamic>? queryParameters}) async {
    final response = await _dio.get(
      ApiConstants.questions,
      queryParameters: queryParameters,
    );
    // BE trả về trực tiếp mảng List<QuestionResponse>, không bọc trong 'items'
    final List data = response.data is List ? response.data : (response.data['items'] ?? []);
    return data.map((e) => QuestionModel.fromJson(e)).toList();
  }

  Future<void> publishQuestion(int id) async {
    await _dio.put('${ApiConstants.questions}/$id/publish');
  }

  Future<void> draftQuestion(int id) async {
    await _dio.put('${ApiConstants.questions}/$id/draft');
  }

  Future<QuestionModel> createQuestion(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.questions, data: data);
    return QuestionModel.fromJson(response.data);
  }

  Future<void> addOption(int questionId, Map<String, dynamic> data) async {
    await _dio.post('${ApiConstants.questions}/$questionId/options', data: data);
  }
}
