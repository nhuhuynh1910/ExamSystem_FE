namespace JWT.DTOs.Exam
{
    public class ExamQuestionOptionResponseDto
    {
        public int OptionId { get; set; }

        public string OptionText { get; set; } = string.Empty;

        public bool? IsCorrect { get; set; }

        public int OptionOrder { get; set; }
    }
}
