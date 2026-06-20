using System.ComponentModel.DataAnnotations;

namespace JWT.DTOs.Auth
{
    public class ResendVerificationEmailRequest
    {
        [Required]
        [EmailAddress]
        [MaxLength(255)]
        public string Email { get; set; } = string.Empty;
    }
}
