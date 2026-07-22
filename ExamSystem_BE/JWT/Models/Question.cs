using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace JWT.Models
{
    public class Question
    {
        [Key]
        public int QuestionId { get; set; }

        public int SubjectId { get; set; }

        public int TeacherId { get; set; }

        [Required]
        public string Content { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string QuestionType { get; set; } = "MultipleChoice";

        [Required]
        [MaxLength(20)]
        public string Difficulty { get; set; } = "Easy";

        [Column(TypeName = "decimal(5,2)")]
        public decimal Score { get; set; }

        [Required]
        [MaxLength(20)]
        public string Status { get; set; } = "Draft";

        public string? Explanation { get; set; }

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

        public ICollection<QuestionOption> QuestionOptions { get; set; } = new List<QuestionOption>();

        public ICollection<ExamQuestion> ExamQuestions { get; set; } = new List<ExamQuestion>();

        public ICollection<AttemptQuestion> AttemptQuestions { get; set; } = new List<AttemptQuestion>();

        public ICollection<StudentAnswer> StudentAnswers { get; set; } = new List<StudentAnswer>();
    }
}
