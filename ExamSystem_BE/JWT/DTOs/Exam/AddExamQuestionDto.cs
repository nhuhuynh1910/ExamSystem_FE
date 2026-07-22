namespace JWT.DTOs.Exam
{
    public class AddExamQuestionDto
    {
        public int QuestionId { get; set; }

        public int? QuestionOrder { get; set; }

        public decimal? Score { get; set; }
    }
}
