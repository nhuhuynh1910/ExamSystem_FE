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
      examId: (json['examId'] as num?)?.toInt() ?? 0,
      subjectId: (json['subjectId'] as num?)?.toInt() ?? 0,
      subjectName: json['subjectName'] as String?,
      teacherId: (json['teacherId'] as num?)?.toInt() ?? 0,
      examName: json['examName'] as String? ?? '',
      description: json['description'] as String?,
      examImageUrl: json['examImageUrl'] as String?,  
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      startTime: _parseDateTime(json['startTime'] as String?) ?? DateTime.now(),
      endTime: _parseDateTime(json['endTime'] as String?) ?? DateTime.now(),
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
      passingScore: (json['passingScore'] as num?)?.toDouble() ?? 0.0,
      maxAttempts: (json['maxAttempts'] as num?)?.toInt() ?? 0,
      isPrivate: json['isPrivate'] as bool? ?? false,
      accessCode: json['accessCode'] as String?,
      shuffleQuestions: json['shuffleQuestions'] as bool? ?? false,
      showAnswerAfterSubmit: json['showAnswerAfterSubmit'] as bool? ?? false,
      status: json['status'] as String? ?? 'Draft',
      createdAt: _parseDateTime(json['createdAt'] as String?) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt'] as String?),
    );
  }

  static DateTime? _parseDateTime(String? str) {
    if (str == null || str.isEmpty) return null;
    return DateTime.tryParse(str)?.toLocal();
  }
}
