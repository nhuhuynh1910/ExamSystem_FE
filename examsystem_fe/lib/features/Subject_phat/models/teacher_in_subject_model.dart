/// TeacherInSubjectModel — GV đang được gán vào một môn học.
/// Map từ BE: TeacherInSubjectDto
class TeacherInSubjectModel {
  final int teacherSubjectId;
  final int teacherId;
  final String fullName;
  final String email;
  final DateTime assignedAt;
  final bool isActive;

  const TeacherInSubjectModel({
    required this.teacherSubjectId,
    required this.teacherId,
    required this.fullName,
    required this.email,
    required this.assignedAt,
    required this.isActive,
  });

  factory TeacherInSubjectModel.fromJson(Map<String, dynamic> json) {
    return TeacherInSubjectModel(
      teacherSubjectId: json['teacherSubjectId'] as int? ?? 0,
      teacherId: json['teacherId'] as int? ?? 0,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      assignedAt: json['assignedAt'] != null
          ? DateTime.tryParse(json['assignedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
