import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

import '../domain/teacher_request_repository_khanh.dart';
import '../models/available_subject_request_model_khanh.dart';

abstract class TeacherRequestStateKhanh {}

class TeacherRequestInitialKhanh extends TeacherRequestStateKhanh {}

class TeacherRequestLoadingKhanh extends TeacherRequestStateKhanh {}

class TeacherRequestLoadedKhanh extends TeacherRequestStateKhanh {
  final List<AvailableSubjectRequestModelKhanh> subjects;

  TeacherRequestLoadedKhanh(this.subjects);
}

class TeacherRequestSubmittingKhanh extends TeacherRequestStateKhanh {
  final List<AvailableSubjectRequestModelKhanh> subjects;

  TeacherRequestSubmittingKhanh(this.subjects);
}

class TeacherRequestSuccessKhanh extends TeacherRequestStateKhanh {
  final String message;
  final List<AvailableSubjectRequestModelKhanh> subjects;

  TeacherRequestSuccessKhanh({
    required this.message,
    required this.subjects,
  });
}

class TeacherRequestErrorKhanh extends TeacherRequestStateKhanh {
  final String message;

  TeacherRequestErrorKhanh(this.message);
}

class TeacherRequestCubitKhanh extends Cubit<TeacherRequestStateKhanh> {
  final TeacherRequestRepositoryKhanh repository;
  List<AvailableSubjectRequestModelKhanh> _subjects = [];

  TeacherRequestCubitKhanh(this.repository)
      : super(TeacherRequestInitialKhanh());

  Future<void> loadAvailableSubjects() async {
    try {
      emit(TeacherRequestLoadingKhanh());

      _subjects = await repository.getAvailableSubjects();

      emit(TeacherRequestLoadedKhanh(_subjects));
    } catch (e) {
      emit(TeacherRequestErrorKhanh(e.toString()));
    }
  }

  Future<void> submitRequest({
    required int subjectId,
    required String reason,
    PlatformFile? certificationFile,
  }) async {
    try {
      emit(TeacherRequestSubmittingKhanh(_subjects));

      await repository.createTeacherRequest(
        subjectId: subjectId,
        reason: reason,
        certificationFile: certificationFile,
      );

      _subjects = await repository.getAvailableSubjects();

      emit(
        TeacherRequestSuccessKhanh(
          message: 'Teacher request sent successfully.',
          subjects: _subjects,
        ),
      );
    } catch (e) {
      emit(TeacherRequestErrorKhanh(e.toString()));
    }
  }
}