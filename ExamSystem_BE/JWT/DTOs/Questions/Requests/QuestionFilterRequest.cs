namespace JWT.DTOs.Questions.Requests
{
    public class QuestionFilterRequest
    {
        public int? SubjectId { get; set; }

        public string? Difficulty { get; set; }

        public string? Status { get; set; }

        public string? QuestionType { get; set; }

        public string? Search { get; set; }

        public int PageNumber { get; set; } = 1;

        public int PageSize { get; set; } = 10;
    }
}