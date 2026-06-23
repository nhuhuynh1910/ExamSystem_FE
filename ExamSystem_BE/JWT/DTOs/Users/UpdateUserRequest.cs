using System.ComponentModel.DataAnnotations;

namespace JWT.DTOs.Users
{
    public class UpdateUserRequest
    {
        [Required]
        [MaxLength(100)]
        public string FullName { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        [MaxLength(255)]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string Username { get; set; } = string.Empty;

        public IFormFile? ProfileImageUrl { get; set; }

        public bool IsActive { get; set; } = true;

        public int RoleId { get; set; }

        [MinLength(6)]
        [RegularExpression(
            @"^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z\d]).{6,}$",
            ErrorMessage = "Mật khẩu phải có ít nhất 6 ký tự, bao gồm chữ, số và ký tự đặc biệt.")]
        public string? Password { get; set; }
    }
}
