using System.ComponentModel.DataAnnotations;

namespace JWT.DTOs.Questions.Requests
{
    public class CreateQuestionOptionRequest
    {
        [Required]
        public string OptionText { get; set; } = string.Empty;

        public bool IsCorrect { get; set; }

        public int OptionOrder { get; set; }
    }
}