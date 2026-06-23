using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace JWT.Models
{
    public class StudentAnswerOption
    {
        [Key]
        public int StudentAnswerOptionId { get; set; }

        public int StudentAnswerId { get; set; }

        public int OptionId { get; set; }

        // Navigation
        [ForeignKey(nameof(StudentAnswerId))]
        public StudentAnswer? StudentAnswer { get; set; }

        [ForeignKey(nameof(OptionId))]
        public QuestionOption? QuestionOption { get; set; }
    }
}
