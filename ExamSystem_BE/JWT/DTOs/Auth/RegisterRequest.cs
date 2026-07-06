using System.ComponentModel.DataAnnotations;

namespace JWT.DTOs.Auth
{
    public class RegisterRequest
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

        [Required]
        [MinLength(6)]
        [RegularExpression(
            @"^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z\d]).{6,}$",
            ErrorMessage = "Mật khẩu phải có ít nhất 6 ký tự, bao gồm chữ, số và ký tự đặc biệt.")]
        public string Password { get; set; } = string.Empty;

        /// <summary>
        /// Role đăng ký: "Student" (default) hoặc "Teacher".
        /// Admin không được phép tự đăng ký.
        /// </summary>
        [MaxLength(50)]
        public string Role { get; set; } = "Student";
    }
}

