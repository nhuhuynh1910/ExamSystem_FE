using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace JWT.Models
{
    public class Exam
    {
        [Key]
        public int ExamId { get; set; }

        public int SubjectId { get; set; }

        public int TeacherId { get; set; }

        [Required]
        [MaxLength(200)]
        public string ExamName { get; set; } = string.Empty;

        public string? Description { get; set; }

        public string? ExamImageUrl { get; set; }

        public int DurationMinutes { get; set; }

        public DateTime StartTime { get; set; }

        public DateTime EndTime { get; set; }

        [Column(TypeName = "decimal(6,2)")]
        public decimal TotalScore { get; set; }

        [Column(TypeName = "decimal(6,2)")]
        public decimal PassingScore { get; set; }

        public int MaxAttempts { get; set; } = 1;

        public bool IsPrivate { get; set; } = false;

        [MaxLength(100)]
        public string? AccessCode { get; set; }

        public bool ShuffleQuestions { get; set; } = false;

        public bool ShowAnswerAfterSubmit { get; set; } = false;

        [Required]
        [MaxLength(20)]
        public string Status { get; set; } = "Draft";

        public bool IsDeleted { get; set; } = false;

        public int? CreatedBy { get; set; }

        public int? UpdatedBy { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public DateTime? UpdatedAt { get; set; }

        [Timestamp]
        public byte[]? RowVersion { get; set; }

        // Navigation
        [ForeignKey(nameof(SubjectId))]
        public Subject? Subject { get; set; }

        [ForeignKey(nameof(TeacherId))]
        public User? Teacher { get; set; }

        public ICollection<ExamQuestion> ExamQuestions { get; set; } = new List<ExamQuestion>();

        public ICollection<ExamAttempt> ExamAttempts { get; set; } = new List<ExamAttempt>();
    }
}
