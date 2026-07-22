import '../data/ranking_api_khanh.dart';
import '../models/ranking_model_khanh.dart';

class RankingRepositoryKhanh {
  final RankingApiKhanh _rankingApi;

  RankingRepositoryKhanh({
    RankingApiKhanh? rankingApi,
  }) : _rankingApi = rankingApi ?? RankingApiKhanh();

  Future<RankingModelKhanh> getRanking({
    required int examId,
    int top = 5,
  }) async {
    return await _rankingApi.getRanking(
      examId: examId,
      top: top,
    );
  }
}