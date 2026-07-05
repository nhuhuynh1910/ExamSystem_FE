import '../models/check_access_response.dart';

/// States cho CheckAccessCubit (POST /api/exams/{examId}/check-access).
sealed class CheckAccessState {
  const CheckAccessState();
}

class CheckAccessInitial extends CheckAccessState {
  const CheckAccessInitial();
}

class CheckAccessLoading extends CheckAccessState {
  const CheckAccessLoading();
}

/// BE trả 200 - canAccess có thể true hoặc false.
class CheckAccessSuccess extends CheckAccessState {
  final CheckAccessResponse response;
  const CheckAccessSuccess({required this.response});
}

/// Lỗi mạng hoặc BE trả 401/403/404/409.
class CheckAccessFailure extends CheckAccessState {
  final String message;
  final int? statusCode;
  const CheckAccessFailure({required this.message, this.statusCode});
}
