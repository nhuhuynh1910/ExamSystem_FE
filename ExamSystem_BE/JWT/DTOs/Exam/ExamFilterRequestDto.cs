namespace JWT.DTOs.Exam
{
    public class ExamFilterRequestDto
    {
        public int? SubjectId { get; set; }

        public int PageNumber { get; set; } = 1;

        public int PageSize { get; set; } = 10;
    }
}
