class ExamModel {
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
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ExamModel({
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

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      examId: json['examId'] ?? 0,
      subjectId: json['subjectId'] ?? 0,
      subjectName: json['subjectName'],
      teacherId: json['teacherId'] ?? 0,
      examName: json['examName'] ?? '',
      description: json['description'],
      examImageUrl: json['examImageUrl'],
      durationMinutes: json['durationMinutes'] ?? 0,
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['endTime'] ?? DateTime.now().toIso8601String()),
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
      passingScore: (json['passingScore'] as num?)?.toDouble() ?? 0.0,
      maxAttempts: json['maxAttempts'] ?? 0,
      isPrivate: json['isPrivate'] ?? false,
      accessCode: json['accessCode'],
      shuffleQuestions: json['shuffleQuestions'] ?? false,
      showAnswerAfterSubmit: json['showAnswerAfterSubmit'] ?? false,
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
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
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'totalScore': totalScore,
    'passingScore': passingScore,
    'maxAttempts': maxAttempts,
    'isPrivate': isPrivate,
    'accessCode': accessCode,
    'shuffleQuestions': shuffleQuestions,
    'showAnswerAfterSubmit': showAnswerAfterSubmit,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}
