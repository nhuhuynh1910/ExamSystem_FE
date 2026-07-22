/// Body của POST /api/exams/{examId}/check-access.
/// accessCode có thể null nếu exam không có private.
class CheckAccessRequest {
  final String? accessCode;

  const CheckAccessRequest({this.accessCode});

  Map<String, dynamic> toJson() => {
        'accessCode': accessCode,
      };
}
