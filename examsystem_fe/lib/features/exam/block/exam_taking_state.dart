
sealed class ExamTakingState {
  const ExamTakingState();
}

class ExamTakingInitial extends ExamTakingState {
  const ExamTakingInitial();
}

class ExamTakingInProgress extends ExamTakingState {
  final int currentQuestionIndex;
  // questionId -> list of selectedOptionIds
  final Map<int, List<int>> answers;
  final bool isSaving;
  final String? saveError;

  const ExamTakingInProgress({
    required this.currentQuestionIndex,
    required this.answers,
    this.isSaving = false,
    this.saveError,
  });

  ExamTakingInProgress copyWith({
    int? currentQuestionIndex,
    Map<int, List<int>>? answers,
    bool? isSaving,
    String? saveError,
  }) {
    return ExamTakingInProgress(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      isSaving: isSaving ?? this.isSaving,
      saveError: saveError,
    );
  }
}

class ExamTakingSubmitting extends ExamTakingState {
  const ExamTakingSubmitting();
}

class ExamTakingSubmitted extends ExamTakingState {
  const ExamTakingSubmitted();
}

class ExamTakingFailure extends ExamTakingState {
  final String message;
  const ExamTakingFailure(this.message);
}
