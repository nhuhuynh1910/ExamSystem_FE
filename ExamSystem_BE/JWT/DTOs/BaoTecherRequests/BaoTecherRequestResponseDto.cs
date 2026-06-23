namespace JWT.DTOs.BaoTecherRequests
{
    public class BaoTecherRequestResponseDto
    {
        public int TeacherRequestId { get; set; }

        public int StudentId { get; set; }

        public string StudentName { get; set; } = string.Empty;

        public string StudentEmail { get; set; } = string.Empty;

        public int SubjectId { get; set; }

        public string SubjectName { get; set; } = string.Empty;

        public string? CertificationUrl { get; set; }

        public string? Reason { get; set; }

        public string Status { get; set; } = string.Empty;

        public string? AdminNote { get; set; }

        public int? ReviewedBy { get; set; }

        public string? ReviewerName { get; set; }

        public DateTime? ReviewedAt { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
