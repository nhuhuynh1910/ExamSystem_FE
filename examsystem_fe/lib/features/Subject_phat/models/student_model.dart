/// StudentModel — Đại diện cho sinh viên đã enroll môn học.
class StudentModel {
  final int studentId;
  final String fullName;
  final String email;
  final DateTime? enrolledAt;

  const StudentModel({
    required this.studentId,
    required this.fullName,
    required this.email,
    this.enrolledAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      studentId: json['studentId'] as int? ?? 0,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      enrolledAt: json['enrolledAt'] != null
          ? DateTime.tryParse(json['enrolledAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'fullName': fullName,
      'email': email,
      'enrolledAt': enrolledAt?.toIso8601String(),
    };
  }
}
