/// Map từ CheckAccessResponse trong BE — trả về bởi POST /api/exams/{examId}/check-access.
class CheckAccessResponse {
  final bool canAccess;
  final int attemptsUsed;
  final int maxAttempts;
  final int remainingAttempts;
  final DateTime checkedAt;

  const CheckAccessResponse({
    required this.canAccess,
    required this.attemptsUsed,
    required this.maxAttempts,
    required this.remainingAttempts,
    required this.checkedAt,
  });

  factory CheckAccessResponse.fromJson(Map<String, dynamic> json) {
    return CheckAccessResponse(
      canAccess:         json['canAccess']         as bool? ?? false,
      attemptsUsed:      (json['attemptsUsed']      as num?)?.toInt() ?? 0,
      maxAttempts:       (json['maxAttempts']       as num?)?.toInt() ?? 0,
      remainingAttempts: (json['remainingAttempts'] as num?)?.toInt() ?? 0,
      checkedAt:         json['checkedAt'] != null
          ? DateTime.tryParse(json['checkedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
