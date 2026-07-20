/// TeacherCourseModel — Đại diện cho môn học được phân công cho Giáo viên.
/// Map từ BE: TeacherSubjectResponseDto
///   { teacherSubjectId, subjectId, subjectName, description, isActive, assignedAt }
class TeacherCourseModel {
  final String code;     // subjectId dạng String — dùng làm route param
  final String name;     // subjectName
  final String semester; // Không có trong BE → mặc định 'Current'
  final int students;    // Không có trong BE → mặc định 0
  final String status;   // isActive → 'Active' / 'Inactive'
  final double progress; // Không có trong BE → mặc định 0.0
  final String nextClass;// Không có trong BE → mặc định ''
  final String room;     // Không có trong BE → mặc định ''

  const TeacherCourseModel({
    required this.code,
    required this.name,
    required this.semester,
    required this.students,
    required this.status,
    required this.progress,
    required this.nextClass,
    required this.room,
  });

  /// Parse TeacherSubjectResponseDto từ BE
  factory TeacherCourseModel.fromJson(Map<String, dynamic> json) {
    final isActive = json['isActive'] as bool? ?? true;
    return TeacherCourseModel(
      code: (json['subjectId'] ?? 0).toString(),
      name: json['subjectName']?.toString() ?? '',
      semester: 'Current',
      students: 0,
      status: isActive ? 'Active' : 'Inactive',
      progress: 0.0,
      nextClass: '',
      room: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'semester': semester,
      'students': students,
      'status': status,
      'progress': progress,
      'nextClass': nextClass,
      'room': room,
    };
  }
}

