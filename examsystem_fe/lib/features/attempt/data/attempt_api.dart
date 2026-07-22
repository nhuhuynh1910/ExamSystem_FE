import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';

class AttemptApi {
  final Dio _dio = DioClient.instance;

  // Kiểm tra quyền truy cập và mã Code
  Future<Map<String, dynamic>> checkAccess(int examId, String? accessCode) async {
    final response = await _dio.post(
      '${ApiConstants.exams}/$examId/check-access',
      data: {'accessCode': accessCode},
    );
    return response.data;
  }

  // Bắt đầu làm bài (Tạo attempt mới hoặc resume)
  Future<Map<String, dynamic>> startExam(int examId, String? accessCode) async {
    final response = await _dio.post(
      '${ApiConstants.exams}/$examId/start',
      data: {'accessCode': accessCode},
    );
    return response.data;
  }

  // Lưu câu trả lời trong khi làm bài
  Future<void> saveAnswer(int attemptId, int questionId, List<int> selectedOptionIds) async {
    await _dio.post(
      '/attempts/$attemptId/answers',
      data: {
        'questionId': questionId,
        'selectedOptionIds': selectedOptionIds,
      },
    );
  }

  // Nộp bài
  Future<Map<String, dynamic>> submitExam(int attemptId) async {
    final response = await _dio.post('/attempts/$attemptId/submit', data: {});
    return response.data;
  }
}
