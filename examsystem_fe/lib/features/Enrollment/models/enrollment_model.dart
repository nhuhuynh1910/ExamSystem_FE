/// EnrollmentModel — Đại diện cho 1 lượt đăng ký môn học của sinh viên.
///
/// Đồng bộ với BE: EnrollmentResponseDto
///   { enrollmentId, studentId, subjectId, subjectName, enrolledAt }
class EnrollmentModel {
  final int enrollmentId;
  final int studentId;
  final int subjectId;
  final String subjectName;
  final DateTime? enrolledAt;

  const EnrollmentModel({
    required this.enrollmentId,
    required this.studentId,
    required this.subjectId,
    required this.subjectName,
    this.enrolledAt,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      enrollmentId: json['enrollmentId'] as int? ?? 0,
      studentId: json['studentId'] as int? ?? 0,
      subjectId: json['subjectId'] as int? ?? 0,
      subjectName: json['subjectName'] as String? ?? '',
      enrolledAt: json['enrolledAt'] != null
          ? DateTime.tryParse(json['enrolledAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enrollmentId': enrollmentId,
      'studentId': studentId,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'enrolledAt': enrolledAt?.toIso8601String(),
    };
  }
}
