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
      
      final responseData = e.response?.data;
      String? serverMsg;
      if (responseData is Map) {
        serverMsg = responseData['message']?.toString() ?? responseData['detail']?.toString();
      }

      final msg = serverMsg != null ? _translateServerMessage(serverMsg) : switch (code) {
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

  String _translateServerMessage(String msg) {
    final lowerMsg = msg.toLowerCase();
    if ((lowerMsg.contains('thời gian') || lowerMsg.contains('thoi gian')) &&
        (lowerMsg.contains('chưa đến') ||
            lowerMsg.contains('chua den') ||
            lowerMsg.contains('chưa tới') ||
            lowerMsg.contains('chua toi'))) {
      return 'The exam has not started yet.';
    }
    if (lowerMsg.contains('thời gian') || lowerMsg.contains('thoi gian')) {
      return 'The exam period has already ended or is not active.';
    }
    if (lowerMsg.contains('chưa enroll') ||
        lowerMsg.contains('chua enroll') ||
        lowerMsg.contains('chưa') ||
        lowerMsg.contains('chua')) {
      return 'You have not enrolled in the subject of this exam.';
    }
    if (lowerMsg.contains('quá') ||
        lowerMsg.contains('qua') ||
        lowerMsg.contains('lượt') ||
        lowerMsg.contains('luot')) {
      return 'You have exceeded the maximum number of attempts allowed for this exam.';
    }
    if (lowerMsg.contains('không đúng') ||
        lowerMsg.contains('khong dung') ||
        lowerMsg.contains('sai')) {
      return 'Incorrect access code. Please try again.';
    }
    return msg;
  }

  void reset() => emit(const CheckAccessInitial());
}
