import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/subject_repository_khanh.dart';
import '../models/subject_model_khanh.dart';

abstract class SubjectStateKhanh {}

class SubjectInitialKhanh extends SubjectStateKhanh {}

class SubjectLoadingKhanh extends SubjectStateKhanh {}

class SubjectLoadedKhanh extends SubjectStateKhanh {
  final List<SubjectModelKhanh> subjects;

  SubjectLoadedKhanh(this.subjects);
}

class SubjectErrorKhanh extends SubjectStateKhanh {
  final String message;

  SubjectErrorKhanh(this.message);
}

class SubjectCubitKhanh extends Cubit<SubjectStateKhanh> {
  final SubjectRepositoryKhanh repository;

  SubjectCubitKhanh(this.repository) : super(SubjectInitialKhanh());

  Future<void> loadAssignedSubjects() async {
    try {
      emit(SubjectLoadingKhanh());

      final subjects = await repository.getAssignedTeachingSubjects();

      emit(SubjectLoadedKhanh(subjects));
    } catch (e) {
      emit(SubjectErrorKhanh(e.toString()));
    }
  }
}