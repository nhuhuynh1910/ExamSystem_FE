import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

import '../domain/teacher_request_repository_khanh.dart';
import '../models/available_subject_request_model_khanh.dart';
import '../models/teacher_request_model_khanh.dart';

abstract class TeacherRequestStateKhanh {
  final List<AvailableSubjectRequestModelKhanh> availableSubjects;
  final List<TeacherRequestModelKhanh> requests;
  final bool isLoading;
  final String? message;
  final String? error;

  TeacherRequestStateKhanh({
    this.availableSubjects = const [],
    this.requests = const [],
    this.isLoading = false,
    this.message,
    this.error,
  });
}

class TeacherRequestInitialKhanh extends TeacherRequestStateKhanh {}

class TeacherRequestLoadingKhanh extends TeacherRequestStateKhanh {
  TeacherRequestLoadingKhanh({
    super.availableSubjects,
    super.requests,
  }) : super(isLoading: true);
}

class TeacherRequestLoadedKhanh extends TeacherRequestStateKhanh {
  TeacherRequestLoadedKhanh({
    required super.availableSubjects,
    required super.requests,
  });
}

class TeacherRequestSuccessKhanh extends TeacherRequestStateKhanh {
  TeacherRequestSuccessKhanh({
    required super.message,
    super.availableSubjects,
    super.requests,
  });
}

class TeacherRequestErrorKhanh extends TeacherRequestStateKhanh {
  TeacherRequestErrorKhanh({
    required super.error,
    super.availableSubjects,
    super.requests,
  });
}

class TeacherRequestCubitKhanh extends Cubit<TeacherRequestStateKhanh> {
  final TeacherRequestRepositoryKhanh repository;

  TeacherRequestCubitKhanh(this.repository)
      : super(TeacherRequestInitialKhanh());

  Future<void> loadAvailableSubjects() async {
    try {
      emit(TeacherRequestLoadingKhanh(
        availableSubjects: state.availableSubjects,
        requests: state.requests,
      ));

      final subjects = await repository.getAvailableSubjects();

      emit(TeacherRequestLoadedKhanh(
        availableSubjects: subjects,
        requests: state.requests,
      ));
    } catch (e) {
      emit(TeacherRequestErrorKhanh(
        error: e.toString(),
        availableSubjects: state.availableSubjects,
        requests: state.requests,
      ));
    }
  }

  Future<void> loadMyRequests() async {
    try {
      emit(TeacherRequestLoadingKhanh(
        availableSubjects: state.availableSubjects,
        requests: state.requests,
      ));

      final requests = await repository.getMyRequests();

      emit(TeacherRequestLoadedKhanh(
        availableSubjects: state.availableSubjects,
        requests: requests,
      ));
    } catch (e) {
      emit(TeacherRequestErrorKhanh(
        error: e.toString(),
        availableSubjects: state.availableSubjects,
        requests: state.requests,
      ));
    }
  }

  Future<void> loadAdminRequests({String? status}) async {
    try {
      emit(TeacherRequestLoadingKhanh(
        availableSubjects: state.availableSubjects,
        requests: state.requests,
      ));

      final requests = await repository.getAdminRequests(status: status);

      emit(TeacherRequestLoadedKhanh(
        availableSubjects: state.availableSubjects,
        requests: requests,
      ));
    } catch (e) {
      emit(TeacherRequestErrorKhanh(
        error: e.toString(),
        availableSubjects: state.availableSubjects,
        requests: state.requests,
      ));
    }
  }

  Future<void> submitRequest({
    required int subjectId,
    required String reason,
    PlatformFile? certificationFile,
  }) async {
    try {
      emit(TeacherRequestLoadingKhanh(
        availableSubjects: state.availableSubjects,
        requests: state.requests,
      ));

      await repository.createTeacherRequest(
        subjectId: subjectId,
        reason: reason,
        certificationFile: certificationFile,
      );

      final myRequests = await repository.getMyRequests();
      final availableSubjects = await repository.getAvailableSubjects();

      emit(TeacherRequestSuccessKhanh(
        message: 'Teacher request sent successfully.',
        availableSubjects: availableSubjects,
        requests: myRequests,
      ));
    } catch (e) {
      emit(TeacherRequestErrorKhanh(
        error: e.toString(),
        availableSubjects: state.availableSubjects,
        requests: state.requests,
      ));
    }
  }

  Future<void> approveRequest(int requestId) async {
    try {
      emit(TeacherRequestLoadingKhanh(
        availableSubjects: state.availableSubjects,
        requests: state.requests,
      ));

      await repository.approveRequest(requestId);
      
      // Reload admin list
      final requests = await repository.getAdminRequests();

      emit(TeacherRequestSuccessKhanh(
        message: 'Request approved successfully.',
        availableSubjects: state.availableSubjects,
        requests: requests,
      ));
    } catch (e) {
      emit(TeacherRequestErrorKhanh(
        error: e.toString(),
        availableSubjects: state.availableSubjects,
        requests: state.requests,
      ));
    }
  }

  Future<void> rejectRequest({
    required int requestId,
    String? adminNote,
  }) async {
    try {
      emit(TeacherRequestLoadingKhanh(
        availableSubjects: state.availableSubjects,
        requests: state.requests,
      ));

      await repository.rejectRequest(
        requestId: requestId,
        adminNote: adminNote,
      );

      // Reload admin list
      final requests = await repository.getAdminRequests();

      emit(TeacherRequestSuccessKhanh(
        message: 'Request rejected.',
        availableSubjects: state.availableSubjects,
        requests: requests,
      ));
    } catch (e) {
      emit(TeacherRequestErrorKhanh(
        error: e.toString(),
        availableSubjects: state.availableSubjects,
        requests: state.requests,
      ));
    }
  }
}
