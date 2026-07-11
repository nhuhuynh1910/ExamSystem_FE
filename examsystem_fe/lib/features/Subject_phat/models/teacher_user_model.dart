/// TeacherUserModel — Tài khoản Giáo viên lấy từ API /api/users.
/// Map từ BE: UserResponse (lọc ra những user có Role = "Teacher")
class TeacherUserModel {
  final int userId;
  final String fullName;
  final String email;
  final String username;
  final bool isActive;

  const TeacherUserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.username,
    required this.isActive,
  });

  factory TeacherUserModel.fromJson(Map<String, dynamic> json) {
    return TeacherUserModel(
      userId: json['userId'] as int? ?? 0,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
