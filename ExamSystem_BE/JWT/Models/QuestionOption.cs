using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace JWT.Models
{
    public class QuestionOption
    {
        [Key]
        public int OptionId { get; set; }

        public int QuestionId { get; set; }

        [Required]
        public string OptionText { get; set; } = string.Empty;

        public bool IsCorrect { get; set; } = false;

        public int OptionOrder { get; set; }

        public bool IsDeleted { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public DateTime? UpdatedAt { get; set; }

        [Timestamp]
        public byte[]? RowVersion { get; set; }

        // Navigation
        [ForeignKey(nameof(QuestionId))]
        public Question? Question { get; set; }

        public ICollection<StudentAnswerOption> StudentAnswerOptions { get; set; } = new List<StudentAnswerOption>();
    }
}
