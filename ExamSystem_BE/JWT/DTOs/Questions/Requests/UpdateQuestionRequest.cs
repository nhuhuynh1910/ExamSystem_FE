using System.ComponentModel.DataAnnotations;

namespace JWT.DTOs.Questions.Requests
{
    public class UpdateQuestionRequest
    {
        [Required]
        public string Content { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string QuestionType { get; set; } = string.Empty;

        [Required]
        [MaxLength(20)]
        public string Difficulty { get; set; } = string.Empty;

        [Range(0.01, 999)]
        public decimal Score { get; set; }

        public string? Explanation { get; set; }

        public byte[]? RowVersion { get; set; }
    }
}