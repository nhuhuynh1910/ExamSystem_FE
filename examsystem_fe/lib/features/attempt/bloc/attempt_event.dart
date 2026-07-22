abstract class AttemptEvent {
  const AttemptEvent();
}

class CheckExamAccessEvent extends AttemptEvent {
  final int examId;
  final String? accessCode;
  const CheckExamAccessEvent(this.examId, this.accessCode);
}

class StartExamAttemptEvent extends AttemptEvent {
  final int examId;
  final String? accessCode;
  const StartExamAttemptEvent(this.examId, this.accessCode);
}
