using Microsoft.AspNetCore.Http;

namespace JWT.DTOs.Exam
{
    public class ExamUpdateDto
    {
        public int SubjectId { get; set; }

        public string ExamName { get; set; } = string.Empty;

        public string? Description { get; set; }

        public IFormFile? ExamImage { get; set; }

        public int DurationMinutes { get; set; }

        public DateTime StartTime { get; set; }

        public DateTime EndTime { get; set; }

        public decimal PassingScore { get; set; }

        public int MaxAttempts { get; set; } = 1;

        public bool IsPrivate { get; set; }

        public string? AccessCode { get; set; }

        public bool ShuffleQuestions { get; set; }

        public bool ShowAnswerAfterSubmit { get; set; }
    }
}