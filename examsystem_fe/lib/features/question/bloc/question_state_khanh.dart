part of 'question_cubit_khanh.dart';

abstract class QuestionStateKhanh {}

class QuestionInitialKhanh extends QuestionStateKhanh {}

class QuestionLoadingKhanh extends QuestionStateKhanh {}

class QuestionLoadedKhanh extends QuestionStateKhanh {
  final List<QuestionModelKhanh> questions;

  QuestionLoadedKhanh(this.questions);
}

class QuestionErrorKhanh extends QuestionStateKhanh {
  final String message;

  QuestionErrorKhanh(this.message);
}