using System.ComponentModel.DataAnnotations;

namespace JWT.DTOs.Users
{
    public class ChangePasswordRequest
    {
        /// <summary>
        /// Mật khẩu hiện tại. Bắt buộc nếu user đã có password.
        /// Nếu user đăng ký bằng Google (chưa có password), để null.
        /// </summary>
        public string? OldPassword { get; set; }

        [Required(ErrorMessage = "Mật khẩu mới không được để trống.")]
        [MinLength(6, ErrorMessage = "Mật khẩu mới phải có ít nhất 6 ký tự.")]
        [MaxLength(100, ErrorMessage = "Mật khẩu mới không được quá 100 ký tự.")]
        public string NewPassword { get; set; } = string.Empty;

        [Required(ErrorMessage = "Xác nhận mật khẩu không được để trống.")]
        [Compare(nameof(NewPassword), ErrorMessage = "Xác nhận mật khẩu không khớp.")]
        public string ConfirmPassword { get; set; } = string.Empty;
    }
}
