import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/ranking_repository_khanh.dart';
import 'ranking_state_khanh.dart';

class RankingCubitKhanh extends Cubit<RankingStateKhanh> {
  final RankingRepositoryKhanh _repository;

  RankingCubitKhanh({
    RankingRepositoryKhanh? repository,
  })  : _repository = repository ?? RankingRepositoryKhanh(),
        super(const RankingInitialKhanh());

  Future<void> loadRanking({
    required int examId,
    int top = 5,
  }) async {
    try {
      emit(const RankingLoadingKhanh());

      final ranking = await _repository.getRanking(
        examId: examId,
        top: top,
      );

      emit(RankingLoadedKhanh(ranking));
    } catch (e) {
      emit(RankingErrorKhanh(e.toString()));
    }
  }

  Future<void> refresh({
    required int examId,
    int top = 5,
  }) async {
    await loadRanking(
      examId: examId,
      top: top,
    );
  }
}