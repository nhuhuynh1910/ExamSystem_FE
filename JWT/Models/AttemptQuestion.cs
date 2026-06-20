using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace JWT.Models
{
    public class AttemptQuestion
    {
        [Key]
        public int AttemptQuestionId { get; set; }

        public int AttemptId { get; set; }

        public int QuestionId { get; set; }

        public int QuestionOrder { get; set; }

        [Column(TypeName = "decimal(5,2)")]
        public decimal Score { get; set; }

        // Navigation
        [ForeignKey(nameof(AttemptId))]
        public ExamAttempt? ExamAttempt { get; set; }

        [ForeignKey(nameof(QuestionId))]
        public Question? Question { get; set; }
    }
}
