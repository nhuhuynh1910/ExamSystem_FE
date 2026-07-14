/// Map từ ProfileResponse.cs trong BE.
///
/// Chứa toàn bộ thông tin hiển thị trên Profile Screen.
/// FE KHÔNG lấy dữ liệu từ StorageManager — luôn gọi API.
class ProfileResponse {
  final int userId;
  final String fullName;
  final String email;
  final String username;
  final String role;
  final String? studentId;
  final String? teacherId;
  final bool isEmailVerified;
  final DateTime createdAt;
  final String? profileImageUrl;
  final bool hasPassword;

  const ProfileResponse({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.username,
    required this.role,
    this.studentId,
    this.teacherId,
    required this.isEmailVerified,
    required this.createdAt,
    this.profileImageUrl,
    required this.hasPassword,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      userId:           json['userId']           as int,
      fullName:         json['fullName']         as String,
      email:            json['email']            as String,
      username:         json['username']         as String,
      role:             json['role']             as String,
      studentId:        json['studentId']        as String?,
      teacherId:        json['teacherId']        as String?,
      isEmailVerified:  json['isEmailVerified']  as bool,
      createdAt:        DateTime.parse(json['createdAt'] as String),
      profileImageUrl:  json['profileImageUrl']  as String?,
      hasPassword:      json['hasPassword']      as bool,
    );
  }

  /// Helper: kiểm tra role
  bool get isStudent => role.toLowerCase() == 'student';
  bool get isTeacher => role.toLowerCase() == 'teacher';
  bool get isAdmin   => role.toLowerCase() == 'admin';

  /// Helper: lấy ID hiển thị theo role
  String? get displayId => isStudent ? studentId : (isTeacher ? teacherId : null);
  String get displayIdLabel => isStudent ? 'Student ID' : (isTeacher ? 'Teacher ID' : 'User ID');

  /// Helper: emoji theo role
  String get roleEmoji => isStudent ? '🎓' : (isTeacher ? '📚' : '🔑');
}
