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
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      // Dùng num? và toInt() / toDouble() với fallback để tránh hoàn toàn crash do Null.
      examId:           (json['examId']          as num?)?.toInt() ?? 0,
      subjectId:        (json['subjectId']        as num?)?.toInt() ?? 0,
      teacherId:        (json['teacherId']        as num?)?.toInt() ?? 0,
      durationMinutes:  (json['durationMinutes']  as num?)?.toInt() ?? 0,
      maxAttempts:      (json['maxAttempts']      as num?)?.toInt() ?? 0,

      // String với fallback rỗng.
      subjectName:      json['subjectName']       as String? ?? '',
      examName:         json['examName']          as String? ?? '',
      description:      json['description']       as String? ?? '',
      status:           json['status']            as String? ?? '',

      // Nullable fields.
      examImageUrl:     json['examImageUrl']      as String?,
      accessCode:       json['accessCode']        as String?,

      // DateTime check null trước khi parse.
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),

      // Double với fallback.
      totalScore:   (json['totalScore']   as num?)?.toDouble() ?? 0.0,
      passingScore: (json['passingScore'] as num?)?.toDouble() ?? 0.0,

      // Bool với fallback.
      isPrivate:             json['isPrivate']             as bool? ?? false,
      shuffleQuestions:      json['shuffleQuestions']      as bool? ?? false,
      showAnswerAfterSubmit: json['showAnswerAfterSubmit'] as bool? ?? false,
    );
  }
}
