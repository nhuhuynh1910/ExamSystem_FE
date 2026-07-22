namespace JWT.DTOs.BaoAccess
{
    public class BaoSaveAnswerResponseDto
    {
        public int StudentAnswerId { get; set; }

        public int AttemptId { get; set; }

        public int QuestionId { get; set; }

        public List<int> SelectedOptionIds { get; set; } = new();

        public DateTime AnsweredAt { get; set; }
    }
}
