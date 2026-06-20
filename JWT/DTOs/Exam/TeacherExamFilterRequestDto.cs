namespace JWT.DTOs.Exam
{
    public class TeacherExamFilterRequestDto
    {
        public int? SubjectId { get; set; }

        public string? Status { get; set; }

        public int PageNumber { get; set; } = 1;

        public int PageSize { get; set; } = 10;
    }
}
