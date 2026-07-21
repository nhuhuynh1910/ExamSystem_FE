import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/question_model.dart';
import '../../exam/models/subject_model.dart';

class QuestionApi {
  final Dio _dio = DioClient.instance;

  Future<List<SubjectModel>> getSubjects() async {
    final teacherSubs = await getTeacherSubjects();
    if (teacherSubs.isNotEmpty) return teacherSubs;

    final response = await _dio.get(ApiConstants.subjects);
    final List data = response.data is List ? response.data : (response.data['items'] ?? []);
    return data.map((json) => SubjectModel.fromJson(json)).toList();
  }

  Future<List<SubjectModel>> getTeacherSubjects() async {
    final response = await _dio.get(ApiConstants.teacherSubjects);
    final List data = response.data is List ? response.data : (response.data['items'] ?? []);

    final List<SubjectModel> subjects = [];
    final Set<int> seenIds = {};

    for (var e in data) {
      final status = (e['status'] ?? e['Status'] ?? "").toString().toLowerCase();
      if (status == "approved") {
        Map<String, dynamic>? s;
        if (e['subject'] is Map) s = Map<String, dynamic>.from(e['subject']);
        else if (e['Subject'] is Map) s = Map<String, dynamic>.from(e['Subject']);
        else s = Map<String, dynamic>.from(e);

        final id = s['subjectId'] ?? s['SubjectId'] ?? s['id'] ?? s['Id'] ?? 
                   e['subjectId'] ?? e['SubjectId'] ?? e['id'] ?? e['Id'] ?? 0;
                   
        final name = s['subjectName'] ?? s['SubjectName'] ?? s['name'] ?? s['Name'] ??
                     e['subjectName'] ?? e['SubjectName'] ?? e['name'] ?? e['Name'] ?? 'Unknown Subject';

        if (id != 0 && !seenIds.contains(id)) {
          subjects.add(SubjectModel(
            subjectId: id,
            subjectName: name,
            description: s['description'] ?? e['description'],
            isActive: true,
          ));
          seenIds.add(id);
        }
      }
    }
    return subjects;
  }

  Future<List<QuestionModel>> getQuestions({Map<String, dynamic>? queryParameters}) async {
    // Convert keys to PascalCase for Backend compatibility if needed, 
    // but here we just pass through and ensure common ones are correct.
    final Map<String, dynamic> params = {};
    if (queryParameters != null) {
      queryParameters.forEach((key, value) {
        if (key.toLowerCase() == 'subjectid') params['SubjectId'] = value;
        else if (key.toLowerCase() == 'difficulty') params['Difficulty'] = value;
        else if (key.toLowerCase() == 'status') params['Status'] = value;
        else if (key.toLowerCase() == 'search') params['Search'] = value;
        else params[key] = value;
      });
    }

    final response = await _dio.get(
      ApiConstants.questions,
      queryParameters: params,
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
