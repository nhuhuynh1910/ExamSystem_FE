namespace JWT.DTOs.Users
{
    public class ProfileResponse
    {
        public int UserId { get; set; }

        public string FullName { get; set; } = string.Empty;

        public string Email { get; set; } = string.Empty;

        public string Username { get; set; } = string.Empty;

        public string Role { get; set; } = string.Empty;

        /// <summary>
        /// ID hiển thị theo role: HExxxxxx (Student) hoặc TExxxxxx (Teacher).
        /// Format từ UserId, không lưu DB riêng.
        /// </summary>
        public string? StudentId { get; set; }

        public string? TeacherId { get; set; }

        public bool IsEmailVerified { get; set; }

        public DateTime CreatedAt { get; set; }

        public string? ProfileImageUrl { get; set; }

        /// <summary>
        /// true nếu user đã có password (đăng ký bằng email).
        /// false nếu user đăng ký bằng Google và chưa set password.
        /// </summary>
        public bool HasPassword { get; set; }
    }
}
