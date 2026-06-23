namespace JWT.DTOs.BaoAccess
{
    public class BaoResultResponseDto
    {
        public int ExamId { get; set; }

        public string ExamName { get; set; } = string.Empty;

        public int AttemptId { get; set; }

        public int AttemptNumber { get; set; }

        public decimal Score { get; set; }

        public decimal TotalScore { get; set; }

        public decimal PassingScore { get; set; }

        public bool IsPassed { get; set; }

        public DateTime StartTime { get; set; }

        public DateTime? SubmitTime { get; set; }

        public double DurationSeconds { get; set; }

        public string Status { get; set; } = string.Empty;

        public bool ShowAnswerAfterSubmit { get; set; }

        public bool CanViewCorrectAnswers { get; set; }

        public List<BaoAttemptQuestionDto> Questions { get; set; } = new();
    }
}
