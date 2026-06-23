namespace JWT.DTOs.Exam
{
    public class ExamQuestionResponseDto
    {
        public int ExamQuestionId { get; set; }

        public int QuestionId { get; set; }

        public int QuestionOrder { get; set; }

        public decimal Score { get; set; }

        public string Content { get; set; } = string.Empty;

        public string QuestionType { get; set; } = string.Empty;

        public string Difficulty { get; set; } = string.Empty;

        public string? Explanation { get; set; }

        public List<ExamQuestionOptionResponseDto> Options { get; set; } = new();
    }
}
