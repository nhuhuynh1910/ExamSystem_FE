namespace JWT.DTOs.BaoAccess
{
    public class BaoAttemptDetailResponseDto
    {
        public int AttemptId { get; set; }

        public int ExamId { get; set; }

        public string ExamName { get; set; } = string.Empty;

        public int StudentId { get; set; }

        public int AttemptNumber { get; set; }

        public DateTime StartTime { get; set; }

        public DateTime? SubmitTime { get; set; }

        public string Status { get; set; } = string.Empty;

        public decimal? Score { get; set; }

        public bool? IsPassed { get; set; }

        public bool ShowAnswerAfterSubmit { get; set; }

        public bool CanViewCorrectAnswers { get; set; }

        public List<BaoAttemptQuestionDto> Questions { get; set; } = new();
    }
}
