import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/attempt_repository.dart';
import 'attempt_event.dart';
import 'attempt_state.dart';

class AttemptBloc extends Bloc<AttemptEvent, AttemptState> {
  final AttemptRepository _repository;

  AttemptBloc(this._repository) : super(const AttemptInitial()) {
    on<CheckExamAccessEvent>(_onCheckAccess);
    on<StartExamAttemptEvent>(_onStartAttempt);
  }

  Future<void> _onCheckAccess(CheckExamAccessEvent event, Emitter<AttemptState> emit) async {
    emit(const AttemptLoading());
    try {
      final result = await _repository.checkAccess(event.examId, event.accessCode);
      emit(ExamAccessChecked(
        canAccess: result['canAccess'] ?? false,
        remainingAttempts: result['remainingAttempts'] ?? 0,
      ));
    } catch (e) {
      emit(AttemptError(e.toString()));
    }
  }

  Future<void> _onStartAttempt(StartExamAttemptEvent event, Emitter<AttemptState> emit) async {
    emit(const AttemptLoading());
    try {
      final result = await _repository.startExam(event.examId, event.accessCode);
      emit(AttemptStarted(result));
    } catch (e) {
      emit(AttemptError(e.toString()));
    }
  }
}
