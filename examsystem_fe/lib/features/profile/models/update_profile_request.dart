/// DTO gửi lên BE khi cập nhật profile.
///
/// Theo yêu cầu: chỉ cho phép sửa FullName.
/// BE vẫn nhận Username và ProfileImageUrl nhưng FE không gửi.
class UpdateProfileRequest {
  final String fullName;

  const UpdateProfileRequest({required this.fullName});

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
    };
  }
}
