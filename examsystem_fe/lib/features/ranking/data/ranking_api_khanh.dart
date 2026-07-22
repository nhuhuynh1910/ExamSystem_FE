import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../models/ranking_model_khanh.dart';

class RankingApiKhanh {
  final Dio _dio = DioClient.instance;

  Future<RankingModelKhanh> getRanking({
    required int examId,
    int top = 5,
  }) async {
    try {
      final response = await _dio.get(
        '/exams/$examId/ranking',
        queryParameters: {
          'top': top,
        },
      );

      return RankingModelKhanh.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            e.message ??
            'Failed to load ranking.',
      );
    }
  }
}