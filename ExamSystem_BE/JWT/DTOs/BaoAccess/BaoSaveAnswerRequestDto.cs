namespace JWT.DTOs.BaoAccess
{
    public class BaoSaveAnswerRequestDto
    {
        public int QuestionId { get; set; }

        public List<int> SelectedOptionIds { get; set; } = new();
    }
}
