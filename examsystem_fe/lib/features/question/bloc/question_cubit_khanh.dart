import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/question_repository_khanh.dart';
import '../models/question_model_khanh.dart';

part 'question_state_khanh.dart';

class QuestionCubitKhanh extends Cubit<QuestionStateKhanh> {
  final QuestionRepositoryKhanh repository;

  QuestionCubitKhanh(this.repository) : super(QuestionInitialKhanh());

  Future<void> loadQuestions({
    int pageNumber = 1,
    int pageSize = 10,
    int? subjectId,
    String? difficulty,
    String? status,
    String? questionType,
    String? search,
  }) async {
    emit(QuestionLoadingKhanh());

    try {
      final questions = await repository.getQuestions(
        pageNumber: pageNumber,
        pageSize: pageSize,
        subjectId: subjectId,
        difficulty: difficulty,
        status: status,
        questionType: questionType,
        search: search,
      );

      emit(QuestionLoadedKhanh(questions));
    } catch (e) {
      emit(QuestionErrorKhanh(e.toString()));
    }
  }

  Future<void> deleteQuestion(int id) async {
    await repository.deleteQuestion(id);
    await loadQuestions();
  }

  Future<void> publishQuestion(int id) async {
    await repository.publishQuestion(id);
    await loadQuestions();
  }

  Future<void> draftQuestion(int id) async {
    await repository.draftQuestion(id);
    await loadQuestions();
  }
}