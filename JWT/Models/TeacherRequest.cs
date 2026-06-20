using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace JWT.Models
{
    public class TeacherRequest
    {
        [Key]
        public int TeacherRequestId { get; set; }

        public int StudentId { get; set; }

        public int SubjectId { get; set; }

        public string? CertificationUrl { get; set; }

        public string? Reason { get; set; }

        [Required]
        [MaxLength(20)]
        public string Status { get; set; } = "Pending";
        // Pending, Approved, Rejected

        public string? AdminNote { get; set; }

        public int? ReviewedBy { get; set; }

        public DateTime? ReviewedAt { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [Timestamp]
        public byte[]? RowVersion { get; set; }

        // Navigation
        [ForeignKey(nameof(StudentId))]
        public User? Student { get; set; }

        [ForeignKey(nameof(SubjectId))]
        public Subject? Subject { get; set; }

        [ForeignKey(nameof(ReviewedBy))]
        public User? Reviewer { get; set; }
    }
}