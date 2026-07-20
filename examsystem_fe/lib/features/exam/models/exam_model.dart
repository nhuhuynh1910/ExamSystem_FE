/// Map từ ExamDto trong BE — một item trong danh sách trả về của GET /api/exams.
class ExamModel {
  final int examId;
  final int subjectId;
  final String subjectName;
  final int teacherId;
  final String examName;
  final String description;
  final String? examImageUrl;
  final int durationMinutes;
  final DateTime? startTime;
  final DateTime? endTime;
  final double totalScore;
  final double passingScore;
  final int maxAttempts;
  final bool isPrivate;
  final String? accessCode; // null với Student (BE không trả về)
  final bool shuffleQuestions;
  final bool showAnswerAfterSubmit;
  final String status;
  final int? questionCount;
  final int? attemptCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExamModel({
    required this.examId,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.examName,
    required this.description,
    this.examImageUrl,
    required this.durationMinutes,
    this.startTime,
    this.endTime,
    required this.totalScore,
    required this.passingScore,
    required this.maxAttempts,
    required this.isPrivate,
    this.accessCode,
    required this.shuffleQuestions,
    required this.showAnswerAfterSubmit,
    required this.status,
    this.questionCount,
    this.attemptCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      // Dùng num? và toInt() / toDouble() với fallback để tránh hoàn toàn crash do Null.
      examId:           (json['examId']          as num?)?.toInt() ?? 0,
      subjectId:        (json['subjectId']       as num?)?.toInt() ?? 0,
      teacherId:        (json['teacherId']       as num?)?.toInt() ?? 0,
      durationMinutes:  (json['durationMinutes'] as num?)?.toInt() ?? 0,
      maxAttempts:      (json['maxAttempts']     as num?)?.toInt() ?? 0,
      questionCount:    (json['questionCount']   as num?)?.toInt() ?? (json['QuestionCount'] as num?)?.toInt(),
      attemptCount:     (json['attemptCount']    as num?)?.toInt() ?? (json['AttemptCount']  as num?)?.toInt(),

      // String với fallback rỗng.
      subjectName:      json['subjectName']       as String? ?? '',
      examName:         json['examName']          as String? ?? '',
      description:      json['description']       as String? ?? '',
      status:           json['status']            as String? ?? '',

      // Nullable fields.
      examImageUrl:     json['examImageUrl']      as String?,
      accessCode:       json['accessCode']        as String?,

      // DateTime check null trước khi parse và chuẩn hóa về local.
      startTime: _parseDateTime(json['startTime'] as String?),
      endTime: _parseDateTime(json['endTime'] as String?),
      createdAt: _parseDateTime(json['createdAt'] as String?) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt'] as String?) ?? DateTime.now(),

      // Double với fallback.
      totalScore:   (json['totalScore']   as num?)?.toDouble() ?? 0.0,
      passingScore: (json['passingScore'] as num?)?.toDouble() ?? 0.0,

      // Bool với fallback.
      isPrivate:             json['isPrivate']             as bool? ?? false,
      shuffleQuestions:      json['shuffleQuestions']      as bool? ?? false,
      showAnswerAfterSubmit: json['showAnswerAfterSubmit'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'examId': examId,
    'subjectId': subjectId,
    'subjectName': subjectName,
    'teacherId': teacherId,
    'examName': examName,
    'description': description,
    'examImageUrl': examImageUrl,
    'durationMinutes': durationMinutes,
    'startTime': startTime?.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'totalScore': totalScore,
    'passingScore': passingScore,
    'maxAttempts': maxAttempts,
    'isPrivate': isPrivate,
    'accessCode': accessCode,
    'shuffleQuestions': shuffleQuestions,
    'showAnswerAfterSubmit': showAnswerAfterSubmit,
    'status': status,
    'questionCount': questionCount,
    'attemptCount': attemptCount,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  static DateTime? _parseDateTime(String? str) {
    if (str == null || str.isEmpty) return null;
    String timeStr = str;
    if (!timeStr.endsWith('Z') && !timeStr.contains(RegExp(r'[+-]\d{2}:\d{2}$'))) {
      timeStr += 'Z';
    }
    return DateTime.tryParse(timeStr)?.toLocal();
  }
}
