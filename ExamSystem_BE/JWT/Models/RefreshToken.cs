using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace JWT.Models
{
    public class RefreshToken
    {
        [Key]
        public int RefreshTokenId { get; set; }

        public int UserId { get; set; }

        [Required]
        public string Token { get; set; } = string.Empty;

        public DateTime ExpiresAt { get; set; }

        public bool IsRevoked { get; set; } = false;

        public string ReplaceByToken { get; set; } = string.Empty;
        public DateTime RevokedAt { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        // Navigation
        [ForeignKey(nameof(UserId))]
        public User? User { get; set; }
    }
}
