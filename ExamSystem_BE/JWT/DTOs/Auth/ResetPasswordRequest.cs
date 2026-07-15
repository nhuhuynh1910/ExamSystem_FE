using System.ComponentModel.DataAnnotations;

namespace JWT.DTOs.Auth
{
    public class ResetPasswordRequest
    {
        [Required]
        public string Token { get; set; } = string.Empty;

        [Required]
        [MinLength(6)]
        [RegularExpression(
            @"^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z\d]).{6,}$",
            ErrorMessage = "Mật khẩu phải có ít nhất 6 ký tự, bao gồm chữ, số và ký tự đặc biệt.")]
        public string NewPassword { get; set; } = string.Empty;
    }
}
