using System.ComponentModel.DataAnnotations;

namespace JWT.DTOs.Users
{
    public class UpdateProfileRequest
    {
        [MaxLength(100)]
        public string? FullName { get; set; }

        [MaxLength(100)]
        public string? Username { get; set; }

        public IFormFile? ProfileImageUrl { get; set; }
    }
}
