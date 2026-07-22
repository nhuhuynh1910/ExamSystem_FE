namespace JWT.DTOs.Subjects
{
    public class EnrollmentResponseDto
    {
        public int EnrollmentId { get; set; }
        public int StudentId { get; set; }
        public int SubjectId { get; set; }
        public string SubjectName { get; set; } = string.Empty;
        public DateTime EnrolledAt { get; set; }
    }
}