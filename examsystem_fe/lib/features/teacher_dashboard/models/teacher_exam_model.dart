/// Model map từ ExamResponseDto.cs của BE.
///
/// JSON response từ GET /api/teacher/exams trả về `PagedResultDto<ExamResponseDto>`.
/// BE serialize PascalCase → camelCase tự động (.NET default).
class TeacherExamModel {
  final int examId;
  final int subjectId;
  final String? subjectName;
  final int teacherId;
  final String examName;
  final String? description;
  final String? examImageUrl;
  final int durationMinutes;
  final DateTime startTime;
  final DateTime endTime;
  final double totalScore;
  final double passingScore;
  final int maxAttempts;
  final bool isPrivate;
  final String? accessCode;
  final bool shuffleQuestions;
  final bool showAnswerAfterSubmit;
  final String status; // 'Draft', 'Published', 'Closed'
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TeacherExamModel({
    required this.examId,
    required this.subjectId,
    this.subjectName,
    required this.teacherId,
    required this.examName,
    this.description,
    this.examImageUrl,
    required this.durationMinutes,
    required this.startTime,
    required this.endTime,
    required this.totalScore,
    required this.passingScore,
    required this.maxAttempts,
    required this.isPrivate,
    this.accessCode,
    required this.shuffleQuestions,
    required this.showAnswerAfterSubmit,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory TeacherExamModel.fromJson(Map<String, dynamic> json) {
    return TeacherExamModel(
      examId: json['examId'] as int,
      subjectId: json['subjectId'] as int,
      subjectName: json['subjectName'] as String?,
      teacherId: json['teacherId'] as int,
      examName: json['examName'] as String,
      description: json['description'] as String?,
      examImageUrl: json['examImageUrl'] as String?,
      durationMinutes: json['durationMinutes'] as int,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      totalScore: (json['totalScore'] as num).toDouble(),
      passingScore: (json['passingScore'] as num).toDouble(),
      maxAttempts: json['maxAttempts'] as int,
      isPrivate: json['isPrivate'] as bool,
      accessCode: json['accessCode'] as String?,
      shuffleQuestions: json['shuffleQuestions'] as bool,
      showAnswerAfterSubmit: json['showAnswerAfterSubmit'] as bool,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
