class TeacherRequestModelKhanh {
  final int teacherRequestId;
  final int studentId;
  final String studentName;
  final String studentEmail;
  final int subjectId;
  final String subjectName;
  final String? certificationUrl;
  final String? reason;
  final String status;
  final String? adminNote;
  final String? reviewerName;
  final DateTime? reviewedAt;
  final DateTime? createdAt;

  TeacherRequestModelKhanh({
    required this.teacherRequestId,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.subjectId,
    required this.subjectName,
    this.certificationUrl,
    this.reason,
    required this.status,
    this.adminNote,
    this.reviewerName,
    this.reviewedAt,
    this.createdAt,
  });

  factory TeacherRequestModelKhanh.fromJson(Map<String, dynamic> json) {
    return TeacherRequestModelKhanh(
      teacherRequestId: json['teacherRequestId'] ?? 0,
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
      studentEmail: json['studentEmail'] ?? '',
      subjectId: json['subjectId'] ?? 0,
      subjectName: json['subjectName'] ?? '',
      certificationUrl: json['certificationUrl'],
      reason: json['reason'],
      status: json['status'] ?? '',
      adminNote: json['adminNote'],
      reviewerName: json['reviewerName'],
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.tryParse(json['reviewedAt']),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt']),
    );
  }
}