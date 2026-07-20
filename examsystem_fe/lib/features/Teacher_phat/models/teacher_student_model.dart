/// TeacherStudentModel — Đại diện cho sinh viên trong Roster của giáo viên.
class TeacherStudentModel {
  final int studentId;
  final String fullName;
  final String email;
  final String status;
  final DateTime? enrolledAt;

  const TeacherStudentModel({
    required this.studentId,
    required this.fullName,
    required this.email,
    required this.status,
    this.enrolledAt,
  });

  factory TeacherStudentModel.fromJson(Map<String, dynamic> json) {
    return TeacherStudentModel(
      studentId: json['studentId'] as int? ?? 0,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      status: json['status'] as String? ?? 'Active',
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
      'status': status,
      'enrolledAt': enrolledAt?.toIso8601String(),
    };
  }
}
