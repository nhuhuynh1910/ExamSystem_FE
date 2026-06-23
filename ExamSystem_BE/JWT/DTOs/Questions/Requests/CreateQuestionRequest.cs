using System.ComponentModel.DataAnnotations;

namespace JWT.DTOs.Questions.Requests
{
    public class CreateQuestionRequest
    {
        [Required]
        public int SubjectId { get; set; }

        [Required]
        public string Content { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string QuestionType { get; set; } = "MultipleChoice";

        [Required]
        [MaxLength(20)]
        public string Difficulty { get; set; } = "Easy";

        [Range(0.01, 999)]
        public decimal Score { get; set; }

        public string? Explanation { get; set; }
    }
}