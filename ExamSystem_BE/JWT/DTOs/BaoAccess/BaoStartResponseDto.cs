namespace JWT.DTOs.BaoAccess
{
    public class BaoStartResponseDto
    {
        public int AttemptId { get; set; }

        public int ExamId { get; set; }

        public int AttemptNumber { get; set; }

        public DateTime StartTime { get; set; }

        public string Status { get; set; } = string.Empty;

        public int QuestionCount { get; set; }

        public bool IsResume { get; set; }
    }
}
