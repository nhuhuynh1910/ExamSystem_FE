/// Model cho mỗi môn học đã đăng ký của Student (My Subjects section).
///
/// Hiện tại dùng mock data vì BE chưa có endpoint riêng.
/// Khi có API, chỉ cần cập nhật fromJson factory.
class StudentSubjectModel {
  final int subjectId;
  final String subjectName;
  final String teacherName;
  final int studentCount;

  const StudentSubjectModel({
    required this.subjectId,
    required this.subjectName,
    required this.teacherName,
    required this.studentCount,
  });

  factory StudentSubjectModel.fromJson(Map<String, dynamic> json) {
    return StudentSubjectModel(
      subjectId: json['subjectId'] as int? ?? 0,
      subjectName: json['subjectName'] as String? ?? '',
      teacherName: json['teacherName'] as String? ?? '',
      studentCount: json['studentCount'] as int? ?? 0,
    );
  }
}
