namespace JWT.DTOs.Questions.Responses
{
    public class QuestionResponse
    {
        public int QuestionId { get; set; }

        public int SubjectId { get; set; }

        public string SubjectName { get; set; } = string.Empty;

        public int TeacherId { get; set; }

        public string TeacherName { get; set; } = string.Empty;

        public string Content { get; set; } = string.Empty;

        public string QuestionType { get; set; } = string.Empty;

        public string Difficulty { get; set; } = string.Empty;

        public decimal Score { get; set; }

        public string Status { get; set; } = string.Empty;

        public string? Explanation { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime? UpdatedAt { get; set; }

        public byte[]? RowVersion { get; set; }

        public List<QuestionOptionResponse> Options { get; set; } = new();
    }
}
