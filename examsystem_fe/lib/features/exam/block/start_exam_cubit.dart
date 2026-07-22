import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/exam_repository.dart';
import 'start_exam_state.dart';

/// Cubit điều phối luồng: Check-Access -> Start -> Load Questions
class StartExamCubit extends Cubit<StartExamState> {
  final ExamRepository _repository;

  StartExamCubit({ExamRepository? repository})
      : _repository = repository ?? ExamRepository(),
        super(const StartExamInitial());

  Future<void> checkAndStartExam({required int examId, String? accessCode}) async {
    emit(const StartExamLoading(statusMessage: 'Checking access permissions...'));

    // 1. Gọi API 1: check-access
    try {
      final accessCheck = await _repository.checkAccess(
        examId: examId,
        accessCode: accessCode,
      );

      if (!accessCheck.canAccess) {
        // Nếu không có quyền truy cập (yêu cầu Access Code)
        emit(StartExamCodeRequired(
          errorMessage: accessCode != null ? 'Incorrect access code. Please try again.' : null,
        ));
        return;
      }
    } on DioException catch (e) {
      final code = e.response?.statusCode;

      final responseData = e.response?.data;
      String? serverMsg;
      if (responseData is Map) {
        serverMsg = responseData['message']?.toString() ?? responseData['detail']?.toString();
      } else if (responseData is String && responseData.trim().startsWith('{')) {
        try {
          final parsed = jsonDecode(responseData);
          if (parsed is Map) {
            serverMsg = parsed['message']?.toString() ?? parsed['detail']?.toString();
          }
        } catch (_) {}
      }

      // Nếu lỗi 403 Forbidden hoặc 401 khi check access
      if (code == 403) {
        if (serverMsg != null) {
          final normalizedMsg = serverMsg.toLowerCase();
          final hasThoiGian = normalizedMsg.contains('thời gian') || normalizedMsg.contains('thoi gian');
          final hasChua = normalizedMsg.contains('chưa') || normalizedMsg.contains('chua');
          final hasQuyen = normalizedMsg.contains('quyền') || normalizedMsg.contains('quyen');
          final hasQua = normalizedMsg.contains('quá') || normalizedMsg.contains('qua');
          final hasLuot = normalizedMsg.contains('lượt') || normalizedMsg.contains('luot');

          if (hasThoiGian || hasChua || hasQuyen || hasQua || hasLuot) {
            emit(StartExamFailure(message: _translateServerMessage(serverMsg), statusCode: code));
            return;
          }
        }

        String? displayMsg = serverMsg != null ? _translateServerMessage(serverMsg) : null;
        emit(StartExamCodeRequired(
          errorMessage: accessCode != null ? (displayMsg ?? 'Incorrect access code. Please try again.') : null,
        ));
        return;
      }

      final errorMsg = serverMsg != null ? _translateServerMessage(serverMsg) : _getDioErrorMessage(e);
      emit(StartExamFailure(message: errorMsg, statusCode: code));
      return;
    } catch (e) {
      emit(StartExamFailure(message: 'Access check error: ${e.toString()}'));
      return;
    }

    // 2. Quyền truy cập hợp lệ -> Gọi API 2: start exam
    emit(const StartExamLoading(statusMessage: 'Creating a new exam attempt...'));
    dynamic startResult;
    try {
      startResult = await _repository.startExam(
        examId: examId,
        accessCode: accessCode,
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final errorMsg = _getDioErrorMessage(e);
      emit(StartExamFailure(message: 'Failed to start exam: $errorMsg', statusCode: code));
      return;
    } catch (e) {
      emit(StartExamFailure(message: 'Start exam error: ${e.toString()}'));
      return;
    }

    // 3. Khởi tạo thành công -> Gọi API 3: get attempt details (includes questions and saved answers)
    emit(const StartExamLoading(statusMessage: 'Loading exam attempt details...'));
    try {
      final attemptDetails = await _repository.getAttemptDetails(startResult.attemptId);
      emit(StartExamSuccess(
        startResponse: startResult,
        questions: attemptDetails.questions,
        attemptStartTime: attemptDetails.startTime,
      ));
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final errorMsg = _getDioErrorMessage(e);
      emit(StartExamFailure(message: 'Failed to load exam questions: $errorMsg', statusCode: code));
    } catch (e) {
      emit(StartExamFailure(message: 'Exam questions loading error: ${e.toString()}'));
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
    if (lowerMsg.contains('quá') || lowerMsg.contains('qua') || lowerMsg.contains('lượt') || lowerMsg.contains('luot')) {
      return 'You have exceeded the maximum number of attempts allowed for this exam.';
    }
    if (lowerMsg.contains('không đúng') || lowerMsg.contains('khong dung') || lowerMsg.contains('sai')) {
      return 'Incorrect access code. Please try again.';
    }
    return msg;
  }

  String _getDioErrorMessage(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.response == null) {
      return 'Server connection error. Please check your network and try again.';
    }

    final code = e.response?.statusCode;

    // Thử lấy message/detail trực tiếp từ server
    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic>) {
      final msg = responseData['message'] as String? ?? responseData['detail'] as String?;
      if (msg != null && msg.isNotEmpty) {
        return _translateServerMessage(msg);
      }
    }

    return switch (code) {
      400  => 'No questions published for this exam.',
      401  => 'Session expired. Please log in again.',
      403  => 'You are not eligible to take this exam.',
      404  => 'Exam details not found.',
      409  => 'You have exceeded the maximum number of attempts.',
      _    => 'Server connection error. Please try again.',
    };
  }

  void reset() {
    if (!isClosed) {
      emit(const StartExamInitial());
    }
  }
}
