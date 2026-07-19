import '../models/ranking_model_khanh.dart';

abstract class RankingStateKhanh {
  const RankingStateKhanh();
}

/// Initial
class RankingInitialKhanh extends RankingStateKhanh {
  const RankingInitialKhanh();
}

/// Loading
class RankingLoadingKhanh extends RankingStateKhanh {
  const RankingLoadingKhanh();
}

/// Success
class RankingLoadedKhanh extends RankingStateKhanh {
  final RankingModelKhanh ranking;

  const RankingLoadedKhanh(this.ranking);
}

/// Error
class RankingErrorKhanh extends RankingStateKhanh {
  final String message;

  const RankingErrorKhanh(this.message);
}