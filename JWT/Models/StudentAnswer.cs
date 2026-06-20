using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace JWT.Models
{
    public class StudentAnswer
    {
        [Key]
        public int StudentAnswerId { get; set; }

        public int AttemptId { get; set; }

        public int QuestionId { get; set; }

        public DateTime AnsweredAt { get; set; } = DateTime.Now;

        public bool IsCorrect { get; set; } = false;

        [Column(TypeName = "decimal(5,2)")]
        public decimal ScoreAwarded { get; set; }

        // Navigation
        [ForeignKey(nameof(AttemptId))]
        public ExamAttempt? ExamAttempt { get; set; }

        [ForeignKey(nameof(QuestionId))]
        public Question? Question { get; set; }

        public ICollection<StudentAnswerOption> StudentAnswerOptions { get; set; } = new List<StudentAnswerOption>();
    }
}
