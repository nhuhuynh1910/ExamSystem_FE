import 'package:dio/dio.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/student_result_model.dart';

class ResultsRepository {
  final Dio _dio;

  ResultsRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  /// Tải danh sách kết quả bài thi của Sinh viên từ API thực tế
  Future<List<StudentResultModel>> fetchStudentResults() async {
    // 1. Tải danh sách bài thi (Exams)
    final examsResponse = await _dio.get(
      ApiConstants.exams,
      queryParameters: {'pageSize': 50},
    );

    final List examItems = examsResponse.data is List
        ? examsResponse.data
        : (examsResponse.data['items'] ?? []);

    final List<StudentResultModel> results = [];

    // 2. Gọi API /api/exams/{id}/result để lấy kết quả đã nộp của sinh viên
    await Future.wait(
      examItems.map((examJson) async {
        final examId = (examJson['examId'] as num?)?.toInt() ?? 0;
        final subjectName = examJson['subjectName'] as String?;
        if (examId > 0) {
          try {
            final res = await _dio.get(
              '${ApiConstants.exams}/$examId/result',
              options: Options(
                validateStatus: (status) => status != null && status < 500,
              ),
            );
            if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
              final resultModel = StudentResultModel.fromJson(
                Map<String, dynamic>.from(res.data as Map),
              );
              results.add(StudentResultModel(
                examId: resultModel.examId,
                examName: resultModel.examName,
                subjectName: subjectName ?? resultModel.subjectName,
                attemptId: resultModel.attemptId,
                attemptNumber: resultModel.attemptNumber,
                score: resultModel.score,
                totalScore: resultModel.totalScore,
                passingScore: resultModel.passingScore,
                isPassed: resultModel.isPassed,
                submitTime: resultModel.submitTime,
                startTime: resultModel.startTime,
                totalQuestions: resultModel.totalQuestions,
                correctAnswers: resultModel.correctAnswers,
              ));
            }
          } catch (_) {
            // Sinh viên chưa làm bài thi này -> Bỏ qua
          }
        }
      }),
    );

    // Sắp xếp kết quả mới nhất lên đầu
    results.sort((a, b) {
      final tA = a.submitTime ?? a.startTime;
      final tB = b.submitTime ?? b.startTime;
      return tB.compareTo(tA);
    });

    return results;
  }
}
