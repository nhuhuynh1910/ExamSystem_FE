using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace JWT.Models
{
    public class User
    {

        [Key]
        public int UserId { get; set; }

        [Required]
        [MaxLength(100)]
        public string FullName { get; set; } = string.Empty;

        [Required]
        [MaxLength(255)]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string Username { get; set; } = string.Empty;

        [Required]
        public string PasswordHash { get; set; } = string.Empty;

        public string? AvatarUrl { get; set; }

        [NotMapped]
        public string? ProfileImageUrl
        {
            get => AvatarUrl;
            set => AvatarUrl = value;
        }

        public int RoleId { get; set; }

        public bool IsEmailVerified { get; set; } = false;

        public string? EmailVerificationToken { get; set; }

        public DateTime? EmailVerificationTokenExpiresAt { get; set; }

        public DateTime? EmailVerifiedAt { get; set; }

        public string? PasswordResetToken { get; set; }

        public DateTime? PasswordResetTokenExpiresAt { get; set; }

        public bool IsActive { get; set; } = true;

        public bool IsDeleted { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public DateTime? UpdatedAt { get; set; }

        [Timestamp]
        public byte[]? RowVersion { get; set; }

        // Navigation
        [ForeignKey(nameof(RoleId))]
        public Role? Role { get; set; }

        public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();

        public ICollection<Enrollment> Enrollments { get; set; } = new List<Enrollment>();

        public ICollection<Question> Questions { get; set; } = new List<Question>();

        public ICollection<Exam> Exams { get; set; } = new List<Exam>();

        public ICollection<ExamAttempt> ExamAttempts { get; set; } = new List<ExamAttempt>();

        public ICollection<Notification> Notifications { get; set; } = new List<Notification>();

        public ICollection<TeacherRequest> SentTeacherRequests { get; set; } = new List<TeacherRequest>();

        public ICollection<TeacherRequest> ReviewedTeacherRequests { get; set; } = new List<TeacherRequest>();
        public ICollection<TeacherSubject> TeacherSubjects { get; set; } = new List<TeacherSubject>();
    }
}
