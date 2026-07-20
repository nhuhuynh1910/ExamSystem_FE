abstract class AttemptState {
  final String? error;
  final bool isLoading;
  const AttemptState({this.error, this.isLoading = false});
}

class AttemptInitial extends AttemptState {
  const AttemptInitial() : super();
}

class AttemptLoading extends AttemptState {
  const AttemptLoading() : super(isLoading: true);
}

class ExamAccessChecked extends AttemptState {
  final bool canAccess;
  final int remainingAttempts;
  const ExamAccessChecked({required this.canAccess, required this.remainingAttempts});
}

class AttemptStarted extends AttemptState {
  final Map<String, dynamic> attemptData;
  const AttemptStarted(this.attemptData);
}

class AttemptError extends AttemptState {
  const AttemptError(String error) : super(error: error);
}
