import '../models/student_result_model.dart';

abstract class ResultsState {
  const ResultsState();
}

class ResultsInitial extends ResultsState {
  const ResultsInitial();
}

class ResultsLoading extends ResultsState {
  const ResultsLoading();
}

class ResultsLoaded extends ResultsState {
  final List<StudentResultModel> results;

  const ResultsLoaded(this.results);
}

class ResultsError extends ResultsState {
  final String message;

  const ResultsError(this.message);
}
