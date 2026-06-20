namespace JWT.DTOs.BaoAccess
{
    public class BaoAttemptQuestionDto
    {
        public int AttemptQuestionId { get; set; }

        public int QuestionId { get; set; }

        public int QuestionOrder { get; set; }

        public string Content { get; set; } = string.Empty;

        public string QuestionType { get; set; } = string.Empty;

        public string Difficulty { get; set; } = string.Empty;

        public decimal Score { get; set; }

        public string? Explanation { get; set; }

        public bool HasAnswer { get; set; }

        public bool? IsCorrect { get; set; }

        public decimal? ScoreAwarded { get; set; }

        public List<int> SelectedOptionIds { get; set; } = new();

        public List<BaoAttemptOptionDto> Options { get; set; } = new();
    }
}
