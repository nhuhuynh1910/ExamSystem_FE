namespace JWT.DTOs.Exam
{
    public class ExamResponseDto
    {
        public int ExamId { get; set; }

        public int SubjectId { get; set; }

        public string? SubjectName { get; set; }

        public int TeacherId { get; set; }

        public string ExamName { get; set; } = string.Empty;

        public string? Description { get; set; }

        public string? ExamImageUrl { get; set; }

        public int DurationMinutes { get; set; }

        public DateTime StartTime { get; set; }

        public DateTime EndTime { get; set; }

        public decimal PassingScore { get; set; }

        public int MaxAttempts { get; set; }

        public bool IsPrivate { get; set; }

        public string? AccessCode { get; set; }

        public bool ShuffleQuestions { get; set; }

        public bool ShowAnswerAfterSubmit { get; set; }

        public string Status { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; }

        public DateTime? UpdatedAt { get; set; }
    }
}
