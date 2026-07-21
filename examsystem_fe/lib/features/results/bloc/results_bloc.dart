import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/results_repository.dart';
import 'results_event.dart';
import 'results_state.dart';

class ResultsBloc extends Bloc<ResultsEvent, ResultsState> {
  final ResultsRepository _repository;

  ResultsBloc({ResultsRepository? repository})
      : _repository = repository ?? ResultsRepository(),
        super(const ResultsInitial()) {
    on<LoadStudentResultsEvent>(_onLoadStudentResults);
  }

  Future<void> _onLoadStudentResults(
    LoadStudentResultsEvent event,
    Emitter<ResultsState> emit,
  ) async {
    emit(const ResultsLoading());
    try {
      final results = await _repository.fetchStudentResults();
      emit(ResultsLoaded(results));
    } catch (e) {
      emit(ResultsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
