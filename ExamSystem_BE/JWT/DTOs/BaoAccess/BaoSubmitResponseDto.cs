namespace JWT.DTOs.BaoAccess
{
    public class BaoSubmitResponseDto
    {
        public int AttemptId { get; set; }

        public int ExamId { get; set; }

        public int AttemptNumber { get; set; }

        public string Status { get; set; } = string.Empty;

        public DateTime StartTime { get; set; }

        public DateTime SubmitTime { get; set; }

        public decimal Score { get; set; }

        public decimal PassingScore { get; set; }

        public decimal TotalScore { get; set; }

        public bool IsPassed { get; set; }

        public bool IsAutoSubmitted { get; set; }

        public int AnsweredQuestions { get; set; }

        public int TotalQuestions { get; set; }
    }
}
