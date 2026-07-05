import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/exam_repository.dart';
import 'check_access_state.dart';

/// Cubit gọi POST /api/exams/{examId}/check-access.
class CheckAccessCubit extends Cubit<CheckAccessState> {
  final ExamRepository _repository;

  CheckAccessCubit({ExamRepository? repository})
    : _repository = repository ?? ExamRepository(),
      super(const CheckAccessInitial());

  Future<void> checkAccess({required int examId, String? accessCode}) async {
    emit(const CheckAccessLoading());
    try {
      final result = await _repository.checkAccess(
        examId: examId,
        accessCode: accessCode,
      );
      emit(CheckAccessSuccess(response: result));
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final msg = switch (code) {
        401  => 'Session expired. Please log in again.',
        403  => 'You are not eligible to take this exam.',
        404  => 'Exam not found.',
        409  => 'You have exceeded the maximum number of attempts.',
        _    => e.message ?? 'An error occurred.',
      };
      emit(CheckAccessFailure(message: msg, statusCode: code));
    } catch (e) {
      emit(CheckAccessFailure(message: e.toString()));
    }
  }

  void reset() => emit(const CheckAccessInitial());
}
