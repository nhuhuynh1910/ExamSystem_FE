using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace JWT.Models
{
    public class ExamQuestion
    {
        [Key]
        public int ExamQuestionId { get; set; }

        public int ExamId { get; set; }

        public int QuestionId { get; set; }

        public int QuestionOrder { get; set; }

        [Column(TypeName = "decimal(5,2)")]
        public decimal Score { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        // Navigation
        [ForeignKey(nameof(ExamId))]
        public Exam? Exam { get; set; }

        [ForeignKey(nameof(QuestionId))]
        public Question? Question { get; set; }
    }
}
