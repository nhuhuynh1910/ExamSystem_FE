namespace JWT.DTOs.BaoTecherRequests
{
    public class BaoTecherRequestAvailableSubjectDto
    {
        public int SubjectId { get; set; }

        public string SubjectName { get; set; } = string.Empty;

        public string? Description { get; set; }
    }
}
