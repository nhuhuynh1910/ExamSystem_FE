using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace JWT.Models
{
    public class ExamAttempt
    {
        [Key]
        public int AttemptId { get; set; }

        public int ExamId { get; set; }

        public int StudentId { get; set; }

        public int AttemptNumber { get; set; }

        public DateTime StartTime { get; set; } = DateTime.Now;

        public DateTime? SubmitTime { get; set; }

        [Column(TypeName = "decimal(6,2)")]
        public decimal Score { get; set; }

        public bool IsPassed { get; set; } = false;

        [Required]
        [MaxLength(20)]
        public string Status { get; set; } = "InProgress";

        public bool IsAutoSubmitted { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public DateTime? UpdatedAt { get; set; }

        [Timestamp]
        public byte[]? RowVersion { get; set; }

        // Navigation
        [ForeignKey(nameof(ExamId))]
        public Exam? Exam { get; set; }

        [ForeignKey(nameof(StudentId))]
        public User? Student { get; set; }

        public ICollection<AttemptQuestion> AttemptQuestions { get; set; } = new List<AttemptQuestion>();

        public ICollection<StudentAnswer> StudentAnswers { get; set; } = new List<StudentAnswer>();
    }
}
