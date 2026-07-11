namespace JWT.DTOs.Subjects
{
    /// <summary>
    /// DTO trả về môn học mà Giáo viên đang được phân công dạy.
    /// Dùng cho endpoint: GET /api/subjects/assigned
    /// </summary>
    public class TeacherSubjectResponseDto
    {
        public int TeacherSubjectId { get; set; }
        public int SubjectId { get; set; }
        public string SubjectName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public bool IsActive { get; set; }
        public DateTime AssignedAt { get; set; }
    }
}
